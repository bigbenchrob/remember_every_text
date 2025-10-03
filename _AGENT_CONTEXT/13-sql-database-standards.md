# SQL Database Standards

## 1. Join Table Naming Scheme

Follow these conventions when defining join tables that connect two existing tables:

- Use the **singular** form of each table name.
- Concatenate the two singular names with the separator `_to_`.
- Order the two names **alphabetically** before joining them.

### Example

To create a join table between the tables `contacts` and `messages`,

- Singularize the names: `contact`, `message`.
- Sort alphabetically: `contact`, `message`.
- Combine with `_to_`: `contact_to_message`.

This naming ensures a predictable, collision-free pattern (`<table_a>_to_<table_b>`) and keeps join tables easy to discover in schema inspections.
