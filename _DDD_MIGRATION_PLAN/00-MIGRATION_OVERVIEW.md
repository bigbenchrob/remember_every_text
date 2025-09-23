# DDD Migration Plan Overview

## Executive Summary

This document outlines the strategic migration plan for transforming the remember_every_text project into a Domain-Driven Design (DDD) architecture. The approach uses a **hybrid "middle-out" strategy** (tracer-bullet approach) to balance domain purity with real-world data validation.

## Architecture Stack

- **Data Extraction**: Rust FFI modules
- **Import Database**: SQLite via sqflite (mirrors Apple data sources)
- **Working Database**: Drift (domain-optimized schema)
- **State Management**: Riverpod with hooks_riverpod
- **Architecture Pattern**: Domain-Driven Design (DDD)

## Strategic Rationale

### Why Middle-Out Approach?

| Approach       | Pros                                    | Cons                                  | Verdict             |
| -------------- | --------------------------------------- | ------------------------------------- | ------------------- |
| **Bottom-Up**  | Fast initial results                    | Hard-codes source quirks into domain  | ❌ Technical debt   |
| **Top-Down**   | Pure domain focus                       | Over-specification without validation | ❌ Risk of rewrites |
| **Middle-Out** | Domain contracts + immediate validation | Requires more upfront planning        | ✅ **Chosen**       |

**Middle-out wins** because it:

- Locks domain contracts first (names, invariants, boundaries)
- Immediately proves feasibility with end-to-end vertical slices
- De-risks assumptions early while maintaining DDD principles
- Validates against Apple's messy real data (attributedBody, handle deduping, etc.)

## Migration Phases

### Phase 1: Domain Contracts (Paper-First, Code-Light)

**Objective**: Define ubiquitous language and core domain invariants

**Key Activities**:

- Define `Chat` aggregate root specifications
- Define `Message` aggregate root specifications
- Establish ID strategies, equality rules, time semantics
- Define attachment and participant policies

**Exit Criteria**:

- ✅ Short ADR (Architecture Decision Record) completed
- ✅ Freezed entity sketches compile successfully
- ✅ Domain invariants expressed as tests (failing tests acceptable)

**Deliverables**:

- `01-DOMAIN_CONTRACTS.md`
- `entities/chat_aggregate.dart` (sketch)
- `entities/message_aggregate.dart` (sketch)
- `test/domain/invariant_tests.dart`

---

### Phase 2: Working Database Schema (Drift)

**Objective**: Design domain-optimized database schema

**Key Activities**:

- Create Drift tables serving domain needs (not mirroring Apple schema)
- Design indices for read paths (chat timeline, unread counts, search)
- Implement basic repository patterns

**Exit Criteria**:

- ✅ Drift schema compiles without errors
- ✅ Basic repository can insert/read Chat + Messages
- ✅ In-memory tests pass for core operations

**Deliverables**:

- `working_database_schema.drift`
- `repositories/chat_repository.dart` (basic)
- `repositories/message_repository.dart` (basic)
- `test/repositories/repository_tests.dart`

---

### Phase 3: Import Database Schema (SQLite)

**Objective**: Create faithful mirror of Apple data sources with minimal ETL preparation

**Key Activities**:

- Mirror macOS chat.db structure in SQLite
- Mirror AddressBook structure with normalization
- Add ETL bookkeeping fields (source_rowid, imported_at, hash, version)
- Focus on mechanical ingestion with minimal transformation

**Exit Criteria**:

- ✅ Import schema handles real Mac backup data
- ✅ CLI dev command successfully loads test dataset
- ✅ Row-count sanity checks pass for imported data

**Deliverables**:

- `import_database_schema.sql`
- `tools/import_data_cli.dart`
- `test/import/data_ingestion_tests.dart`

---

### Phase 4: ETL/Migration Pipeline

**Objective**: Build deterministic, idempotent data transformation pipeline

**Key Activities**:

- Implement Import → Transform → Working pipeline
- Add batch upserts with conflict resolution policies
- Implement change detection (hash/version-based)
- Add comprehensive ETL logging
- Build value-accessor guards for null/shape errors

**Exit Criteria**:

- ✅ Repeatable runs produce identical working.db
- ✅ Re-runs after source changes only touch expected rows
- ✅ Pipeline handles real-world data edge cases

**Deliverables**:

- `migration/etl_pipeline.dart`
- `migration/conflict_resolution.dart`
- `migration/change_detection.dart`
- `test/migration/pipeline_tests.dart`

---

### Phase 5: Repositories & Application Services

**Objective**: Implement clean domain boundaries with proper abstraction layers

**Key Activities**:

- Build aggregate-aligned repositories (ChatRepository, MessageRepository)
- Isolate and test database mapping layers
- Implement application services/use-cases
- Create service boundaries (ImportData, UpdateData, GetChatTimeline, etc.)

**Exit Criteria**:

- ✅ No direct database calls in UI layer
- ✅ All database access goes through repositories
- ✅ Use-cases handle business logic properly
- ✅ Dev commands exercise full read paths via repositories

**Deliverables**:

- `repositories/` (production implementations)
- `application/services/` (use-cases)
- `application/interfaces/` (repository contracts)
- `test/application/service_tests.dart`

---

### Phase 6: Presentation + State (Riverpod)

**Objective**: Wire UI state management through clean service boundaries

**Key Activities**:

- Build feature-scoped Riverpod providers
- Wire providers around use-cases (not direct repositories)
- Implement reactive state management
- Build minimal UI to validate end-to-end flow

**Exit Criteria**:

- ✅ Chat list screen renders using repository data
- ✅ Conversation view opens using use-cases only
- ✅ No direct database or repository calls in UI widgets
- ✅ State management reactive and predictable

**Deliverables**:

- `providers/` (feature-scoped)
- `presentation/widgets/` (updated)
- `presentation/screens/` (updated)
- UI integration tests

---

### Phase 7: Hardening & Operations

**Objective**: Production readiness with reliability and maintainability features

**Key Activities**:

- Add migration versioning system
- Implement database integrity checks
- Build repair tools (re-hydrate corrupted threads)
- Add comprehensive monitoring and logging
- Performance optimization

**Exit Criteria**:

- ✅ Can restore working.db from import.db deterministically
- ✅ Migration system handles version upgrades gracefully
- ✅ Integrity checks catch and report data corruption
- ✅ Performance meets requirements for large datasets

**Deliverables**:

- `migration/versioning.dart`
- `tools/integrity_checker.dart`
- `tools/repair_utilities.dart`
- `monitoring/performance_metrics.dart`
- Production deployment guide

## Success Metrics

### Technical Metrics

- **Test Coverage**: >90% for domain and application layers
- **Build Time**: <30 seconds for full clean build
- **Migration Time**: <5 minutes for 100k messages
- **Memory Usage**: <200MB for typical dataset

### Domain Quality Metrics

- **Cyclomatic Complexity**: <10 for any single method
- **Dependency Direction**: No domain dependencies on infrastructure
- **Aggregate Cohesion**: Clear boundaries, minimal cross-aggregate queries
- **Ubiquitous Language**: Consistent terminology across code and docs

## Risk Mitigation

### High-Risk Areas

1. **Apple Data Quirks**: attributedBody decoding, service variations
2. **Performance**: Large message datasets (100k+ messages)
3. **Data Integrity**: Corruption during migration or updates
4. **User Experience**: Migration downtime and progress feedback

### Mitigation Strategies

- Comprehensive integration tests with real Apple data samples
- Incremental migration with rollback capabilities
- Extensive logging and monitoring throughout pipeline
- Progressive disclosure of migration progress to users

## Next Steps

1. **Immediate**: Review and approve this migration plan
2. **Phase 1 Start**: Begin domain contracts definition
3. **Weekly Reviews**: Assess progress against exit criteria
4. **Adjust**: Refine plan based on real implementation learnings

---

## Document Index

As implementation progresses, this folder will contain:

- `01-DOMAIN_CONTRACTS.md` - Ubiquitous language and entity definitions
- `02-AGGREGATE_BOUNDARIES.md` - Aggregate roots, boundaries, and rationale
- `02-DATABASE_SCHEMAS.md` - Working and import database designs
- `03-ETL_PIPELINE.md` - Data transformation specifications
- `04-REPOSITORY_PATTERNS.md` - Data access layer design
- `05-APPLICATION_SERVICES.md` - Use-case implementations
- `06-PRESENTATION_LAYER.md` - UI and state management patterns
- `07-OPERATIONS_GUIDE.md` - Deployment and maintenance procedures
- `LESSONS_LEARNED.md` - Implementation insights and adjustments
- `PERFORMANCE_BENCHMARKS.md` - Performance testing results
- `TROUBLESHOOTING_GUIDE.md` - Common issues and solutions

**Status**: 📋 Planning Phase  
**Next Milestone**: Phase 1 - Domain Contracts  
**Target Completion**: TBD based on scope validation
