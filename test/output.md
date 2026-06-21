Rune Description
================

A rune description describes the authorization grants for a domain.

*   **type:** object
*   **required:** domain, expires, identity, grants
*   **additionalProperties:** false

### Properties

#### domain

The domain the rune description is associated with.

*   **type:** string
*   **pattern:** `^([a-z0-9\-]+\.[a-z0-9\-]+){1,}\.[a-z]+$`

#### expires

See [Expires](#/$defs/expires).

#### identity

The identity the rune is associated with.

*   **type:** string

#### resolvers

A dictionary of resolvers.

*   **type:** object
*   **patternProperties:**
    *   **`^[A-Za-z0-9\-]+$`:** [Resolver](#/$defs/resolver)
*   **minProperties:** 1
*   **additionalProperties:** false

#### grants

An array of grants.

*   **type:** array
*   **items:** [Grant](#/$defs/grant)

Action
------

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

*   **type:** object
*   **anyOf:**
    *   *   **required:** name, value
    *   *   **required:** name, action
    *   *   **required:** name

### Properties

#### name

The name of the rule action.

*   **type:** string

#### value

The operand for the action, if any.

*   **type:** string, object, array

#### action

See [Action](#/$defs/action).

Expires
-------

A duration object that represents when the rune expires.

*   **type:** object
*   **minProperties:** 1

### Properties

#### years

*   **type:** integer

#### months

*   **type:** integer

#### weeks

*   **type:** integer

#### days

*   **type:** integer

#### hours

*   **type:** integer

#### minutes

*   **type:** integer

#### seconds

*   **type:** integer

#### milliseconds

*   **type:** integer

#### microseconds

*   **type:** integer

#### nanoseconds

*   **type:** integer

Resolver
--------

A resolver consists of an action.

*   **type:** object
*   **required:** action

### Properties

#### action

See [Action](#/$defs/action).

Grant
-----

A grant consists of a list of resources, methods, resolvers, and bindings. It describes which methods and bindings are authorized for a list of resources.

*   **type:** object
*   **required:** resources, methods, bindings

### Properties

#### resources

A list of resources the grant applies to.

*   **type:** object, array
*   **properties:**
    *   **include:**
        *   **type:** array
        *   **items:**
            *   **type:** string
            *   **pattern:** `^(([A-Za-z0-9\-])([ ]{0,1}))+$`
    *   **exclude:**
        *   **type:** array
        *   **items:**
            *   **type:** string
            *   **pattern:** `^(([A-Za-z0-9\-])([ ]{0,1}))+$`
*   **maxProperties:** 1
*   **additionalProperties:** false
*   **items:**
    *   **type:** string
    *   **pattern:** `^(([A-Za-z0-9\-])([ ]{0,1}))+$`

#### methods

A list of methods the grant applies to.

*   **type:** array
*   **items:**
    *   **type:** string
    *   **pattern:** `^[Gg][Ee][Tt]$|^[Pp][Oo][Ss][Tt]$|^[Pp][Uu][Tt]$|^[Dd][Ee][Ll][Ee][Tt][Ee]$`

#### resolvers

A list of resolvers the grant relies on.

*   **type:** array
*   **items:**
    *   **type:** string
    *   **pattern:** `^[A-Za-z0-9\-]+$`

#### bindings

A dictionary of bindings the grant applies to.

*   **type:** object
*   **patternProperties:**
    *   **`^[A-Za-z0-9_]+$`:**
        *   **type:** string
*   **minProperties:** 1
*   **additionalProperties:** false