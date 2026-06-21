Rune Description
================

**Type:** _Object_. A rune description describes the authorization grants for a domain.

*   **additionalProperties:** false

### Required Properties

domain, expires, identity, grants

### Properties

#### Domain

**Type:** _String_. The domain the rune description is associated with.

*   **pattern:** `^([a-z0-9\-]+\.[a-z0-9\-]+){1,}\.[a-z]+$`

#### Expires

**Type:** _Object_. A duration object that represents when the rune expires.

See [Expires](#/$defs/expires).

#### Identity

**Type:** _String_. The identity the rune is associated with.

#### Resolvers

**Type:** _Object_. A dictionary of resolvers.

*   **patternProperties:**
    *   **`^[A-Za-z0-9\-]+$`:** [Resolver](#/$defs/resolver)
*   **minProperties:** 1
*   **additionalProperties:** false

#### Grants

**Type:** _Array_. An array of grants.

*   **items:** [Grant](#/$defs/grant)

Action
------

**Type:** _Object_. A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

*   **anyOf:**
    *   *   **required:** name, value
    *   *   **required:** name, action
    *   *   **required:** name

### Properties

#### Name

**Type:** _String_. The name of the rule action.

#### Value

**Type:** _String, Object, Array_. The operand for the action, if any.

#### Action

**Type:** _Object_. A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

See [Action](#/$defs/action).

Grant Resources
---------------

**Type:** _Object, Array_. A list of resources the grant applies to.

*   **maxProperties:** 1
*   **additionalProperties:** false
*   **items:**
    *   **type:** string
    *   **pattern:** `^(([A-Za-z0-9\-])([ ]{0,1}))+$`

### Properties

#### Include

**Type:** _Array_.

*   **items:**
    *   **type:** string
    *   **pattern:** `^(([A-Za-z0-9\-])([ ]{0,1}))+$`

#### Exclude

**Type:** _Array_.

*   **items:**
    *   **type:** string
    *   **pattern:** `^(([A-Za-z0-9\-])([ ]{0,1}))+$`

Expires
-------

**Type:** _Object_. A duration object that represents when the rune expires.

*   **minProperties:** 1

### Properties

#### Years

**Type:** _Integer_.

#### Months

**Type:** _Integer_.

#### Weeks

**Type:** _Integer_.

#### Days

**Type:** _Integer_.

#### Hours

**Type:** _Integer_.

#### Minutes

**Type:** _Integer_.

#### Seconds

**Type:** _Integer_.

#### Milliseconds

**Type:** _Integer_.

#### Microseconds

**Type:** _Integer_.

#### Nanoseconds

**Type:** _Integer_.

Resolver
--------

**Type:** _Object_. A resolver consists of an action.

### Required Properties

action

### Properties

#### Action

**Type:** _Object_. A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

See [Action](#/$defs/action).

Grant
-----

**Type:** _Object_. A grant consists of a list of resources, methods, resolvers, and bindings. It describes which methods and bindings are authorized for a list of resources.

### Required Properties

resources, methods, bindings

### Properties

#### Resources

**Type:** _Object, Array_. A list of resources the grant applies to.

See [Grant Resources](#/$defs/GrantResources).

#### Methods

**Type:** _Array_. A list of methods the grant applies to.

*   **items:**
    *   **type:** string
    *   **pattern:** `^[Gg][Ee][Tt]$|^[Pp][Oo][Ss][Tt]$|^[Pp][Uu][Tt]$|^[Dd][Ee][Ll][Ee][Tt][Ee]$`

#### Resolvers

**Type:** _Array_. A list of resolvers the grant relies on.

*   **items:**
    *   **type:** string
    *   **pattern:** `^[A-Za-z0-9\-]+$`

#### Bindings

**Type:** _Object_. A dictionary of bindings the grant applies to.

*   **patternProperties:**
    *   **`^[A-Za-z0-9_]+$`:**
        *   **type:** string
*   **minProperties:** 1
*   **additionalProperties:** false