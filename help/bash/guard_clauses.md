# Guard Clause Rules

## Do Guard

```
These are cases where failure must abort the helper or the orchestrator.
They all share the same invariant: multi‑step mutation or conditional context where set -e will not protect you.
```

- **If failure should abort**
    - do guard

- **Procedural installers**
    - do guard every command in every step mutates state

- **Function calls inside conditionals**
    - do guard the call if set -e suppressed

- **Teardown helpers** 
    - do guard if destructive operations must abort on failure

- **Bypass helpers (at call site)**
    - do guard call site
        - don't guard helper itself
    
- **Native install and manual fallback (call site)**
    - do guard native install call if failure should abort before fallback

## Don't Guard

```
These are cases where failure is expected, non‑fatal, or part of a selector/dispatcher pattern.
Invariant: no state mutation + fallback chaining must continue.
```

- **Dispatchers**
    - don't guard

- **Selector fallbacks** 
    - don't guard inside 
        - guard only the outer call
    
- **Native install and manual fallback (inside helper)**
    - don't guard native helper itself

- **Bypass helpers (inside helper)**
    - don't guard inside

- **Manual fallback helpers** 
    - don't guard inside

- **Atomic commands outside conditionals** 
    - don't guard

- **If failure should fall back** 
    - don't guard
