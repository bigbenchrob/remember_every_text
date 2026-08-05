THE RULES OF PRESENCE

=====WHAT ARE THE ACTORS IN PRESENCE?

- a CONTRACTING ENTITY owns/initiates a JOURNEY. When the journey is finished, it sends a [JOURNEY END| signal to the parent contracting entity to inform it of this
- A JOURNEY owns an ordered set of STEPS. It progresses through the steps by incrementing its STEP COUNTER. When there are no more steps, the journey is finished.
- An AGENT is a self contained piece of code that can do something like opening or accessing a database, opening a System Settings panel etc. It does this on behalf of a STEP, as steps are simple by design and contain only the simple logic used to determine if they are finished

=====WHAT TYPES OF JOURNEYS ARE THERE?

- only one

=====WHAT TYPES OF STEPS ARE THERE?

- so far, there are four:
  (1) [TELL] This fades in a message and after a defined interval fades it out. Then the step is finished
  (2) [ASK] This puts up some sort of user input device. When a satisfactory response is achieved the step is finished
  (3) [DO] This type of step directs an agent to do something external to the journey. It does not "do" anything itself
  (4) [AUDIT] This asks a yes/no question. The allows a type of branching behaviour (see below)

=====WHAT TYPES OF PARENT-CHILD RELATIONSHIPS ARE THERE

- A JOURNEY is trivially the child of the CONTRACTING ENTITY
- A STEP is the child of a single JOURNEY
- An AGENT is not really the "child" of a DO or AUDIT STEP in the sense of being part of the hierarchy. Rather, it carries out a task for the step and reports back
- **\*** A JOURNEY can be the child of a STEP. It cannot be the direct child of another JOURNEY **\***

========WHAT TYPES OF SIGNALS ARE PASSED AND WHAT DO THEY MEAN?

- signals are always passed upward to the parent, never in the other direction. There are only two types:

(1) I, the child have finished
(2) You the parent, should finish prematurely

So:
(1) Journey to contracting entity (just once, when the journey finishes): JOURNEY FINISHED

(2) Step to parent journey, either:

     -- [STEP FINISHED] = I as a step have nothing further to do
     -- [TERMINATE JOURNEY] - You, the journey are terminated, as something has happened that requires you not to continue.

(3) journey to parent step:

     -- [FINISH STEP] - Either:
             (1) I as a journey, finished, so there's nothing more to do

                    OR

             (2) Something happened that indicates I don't need to finish to my last step -- you can continue.

          ***** A journey can't tell a step "Don't finish" because a step doesn't have a chain of children. If the journey was not successful it just doesn't tell the parent step to consider itself finished.

NO OTHER SIGNALS ARE POSSIBLE. Just (1) I'm finished and (2) You, my parent should finish prematurely.

=====SIMPLE EXAMPLE OF HOW THIS ALLOWS BRANCHING:

-- onboarding shows some TELL steps, then reaches an AUDIT whose job it is to determine whether FDA has been granted

-- AUDIT STEP initiates an FDA AUDIT Journey

-- the first step of this journey is an ASK STEP. It summons an agent that can answer the question of whether FDA has been granted. The FDA will answer either YES or NO

-- If the answer is YES:

    -- This first step semds its parent FDA JOURNEY [TERMINATE JOURNEY]
    -- The journey, realizing that it is finished, considers itself successful and sends the parent AUDIT STEP [JOURNEY FINISHED]
    -- The AUDIT STEP, its child journey finished, sends the parent onboarding journey [STEP FINISHED]
    -- the onboarding journey continues with the next step, which depended on FDA having been granted.

--IF the answer is NO (as it will be for the maiden run of the application on a new computer):

    -- The ask step sends the FDA JOURNEY [STEP FINISHED]
    -- FDA Journey does what all journeys do when they receive this signal, and moves onto the next step, in its series, which are designed to guid the user through assigning FDA access in the System Settings control panel.

NOTE: I"m thinking that a [REPEAT JOURNEY] signal might handle the situation where the user was guided through assigning FDA. When they returned, an FDA AUDIT repeat journey would cause the journey to restart at the initial ASK (is FDA granted?). If so, this will break out of the journey just as it would have at the beginning if the answer had been yes.
