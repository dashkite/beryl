Rune Description
================

A rune description describes the authorization grants for a domain.

*   **type:** object
*   **properties:**
    *   **domain:**
        *   **description:** The domain the rune description is associated with.
        *   **type:** string
        *   **pattern:** ^(\[a-z0-9\\-\]+\\.\[a-z0-9\\-\]+){1,}\\.\[a-z\]+$
    *   **expires:**
        *   **$ref:** [Go to Reference](#/$defs/expires)
    *   **identity:**
        *   **description:** The identity the rune is associated with.
        *   **type:** string
    *   **resolvers:**
        *   **description:** A dictionary of resolvers.
        *   **type:** object
        *   **patternProperties:**
            *   **^\[A-Za-z0-9\\-\]+$:**
                *   **$ref:** [Go to Reference](#/$defs/resolver)
        *   **minProperties:** 1
        *   **additionalProperties:** false
    *   **grants:**
        *   **description:** An array of grants.
        *   **type:** array
        *   **items:**
            *   **$ref:** [Go to Reference](#/$defs/grant)
*   **required:** domain, expires, identity, grants
*   **additionalProperties:** false

Action
------

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

*   **type:** object
*   **properties:**
    *   **name:**
        *   **description:** The name of the rule action.
        *   **type:** string
    *   **value:**
        *   **description:** The operand for the action, if any.
        *   **type:** string, object, array
    *   **action:**
        *   **$ref:** [Go to Reference](#/$defs/action)
*   **anyOf:**
    *   *   **required:** name, value
    *   *   **required:** name, action
    *   *   **required:** name

Expires
-------

A duration object that represents when the rune expires.

*   **type:** object
*   **properties:**
    *   **years:**
        *   **type:** integer
    *   **months:**
        *   **type:** integer
    *   **weeks:**
        *   **type:** integer
    *   **days:**
        *   **type:** integer
    *   **hours:**
        *   **type:** integer
    *   **minutes:**
        *   **type:** integer
    *   **seconds:**
        *   **type:** integer
    *   **milliseconds:**
        *   **type:** integer
    *   **microseconds:**
        *   **type:** integer
    *   **nanoseconds:**
        *   **type:** integer
*   **minProperties:** 1

Resolver
--------

A resolver consists of an action.

*   **type:** object
*   **properties:**
    *   **action:**
        *   **$ref:** [Go to Reference](#/$defs/action)
*   **required:** action

Grant
-----

A grant consists of a list of resources, methods, resolvers, and bindings. It describes which methods and bindings are authorized for a list of resources.

*   **type:** object
*   **properties:**
    *   **resources:**
        *   **description:** A list of resources the grant applies to.
        *   **type:** object, array
        *   **properties:**
            *   **include:**
                *   **type:** array
                *   **items:**
                    *   **type:** string
                    *   **pattern:** ^((\[A-Za-z0-9\\-\])(\[ \]{0,1}))+$
            *   **exclude:**
                *   **type:** array
                *   **items:**
                    *   **type:** string
                    *   **pattern:** ^((\[A-Za-z0-9\\-\])(\[ \]{0,1}))+$
        *   **maxProperties:** 1
        *   **additionalProperties:** false
        *   **items:**
            *   **type:** string
            *   **pattern:** ^((\[A-Za-z0-9\\-\])(\[ \]{0,1}))+$
    *   **methods:**
        *   **description:** A list of methods the grant applies to.
        *   **type:** array
        *   **items:**
            *   **type:** string
            *   **pattern:** ^\[Gg\]\[Ee\]\[Tt\]$|^\[Pp\]\[Oo\]\[Ss\]\[Tt\]$|^\[Pp\]\[Uu\]\[Tt\]$|^\[Dd\]\[Ee\]\[Ll\]\[Ee\]\[Tt\]\[Ee\]$
    *   **resolvers:**
        *   **description:** A list of resolvers the grant relies on.
        *   **type:** array
        *   **items:**
            *   **type:** string
            *   **pattern:** ^\[A-Za-z0-9\\-\]+$
    *   **bindings:**
        *   **description:** A dictionary of bindings the grant applies to.
        *   **type:** object
        *   **patternProperties:**
            *   **^\[A-Za-z0-9\_\]+$:**
                *   **type:** string
        *   **minProperties:** 1
        *   **additionalProperties:** false
*   **required:** resources, methods, bindings