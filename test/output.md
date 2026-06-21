Rune Description
================

A rune description describes the authorization grants for a domain.

| Name | Value |
| --- | --- |
| Type | Object |
| Required Properties | [Domain](#domain), [Expires](#expires), [Identity](#identity), [Grants](#grants) |
| Additional Properties | false |

### Properties

#### Domain

The domain the rune description is associated with.

See: [Rune Description Domain](#rune-description-domain)

#### Expires

A duration object that represents when the rune expires.

See: [Expires](#expires)

#### Identity

The identity the rune is associated with.

| Name | Value |
| --- | --- |
| Type | String |

#### Resolvers

A dictionary of resolvers.

See: [Rune Description Resolvers](#rune-description-resolvers)

#### Grants

An array of grants.

See: [Rune Description Grants](#rune-description-grants)

Action
------

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

| Name | Value |
| --- | --- |
| Type | Object |
| Any Of | [Action Variation 1](#action-variation-1), [Action Variation 2](#action-variation-2), or [Action Variation 3](#action-variation-3) |

### Properties

#### Name

The name of the rule action.

| Name | Value |
| --- | --- |
| Type | String |

#### Value

The operand for the action, if any.

| Name | Value |
| --- | --- |
| Type | String, Object, or Array |

#### Action

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

See: [Action](#action)

Action Variation 1
------------------

| Name | Value |
| --- | --- |
| Required Properties | [Name](#name), [Value](#value) |

Action Variation 2
------------------

| Name | Value |
| --- | --- |
| Required Properties | [Name](#name), [Action](#action) |

Action Variation 3
------------------

| Name | Value |
| --- | --- |
| Required Properties | [Name](#name) |

Grant Resources
---------------

A list of resources the grant applies to.

| Name | Value |
| --- | --- |
| Type | Object or Array |
| Max Properties | 1 |
| Additional Properties | false |

See: [Grant Resources Items](#grant-resources-items)

### Properties

#### Include

See: [Grant Resources Include](#grant-resources-include)

#### Exclude

See: [Grant Resources Exclude](#grant-resources-exclude)

Grant Methods
-------------

A list of methods the grant applies to.

| Name | Value |
| --- | --- |
| Type | Array |

See: [Grant Methods Items](#grant-methods-items)

Grant Resolvers
---------------

A list of resolvers the grant relies on.

| Name | Value |
| --- | --- |
| Type | Array |

See: [Grant Resolvers Items](#grant-resolvers-items)

Grant Bindings
--------------

A dictionary of bindings the grant applies to.

| Name | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |
| Additional Properties | false |
| Properties matching `^[A-Za-z0-9_]+$` | Type: String |

Resolver
--------

A resolver consists of an action.

| Name | Value |
| --- | --- |
| Type | Object |
| Required Properties | [Action](#action) |

### Properties

#### Action

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

See: [Action](#action)

Grant
-----

A grant consists of a list of resources, methods, resolvers, and bindings. It describes which methods and bindings are authorized for a list of resources.

| Name | Value |
| --- | --- |
| Type | Object |
| Required Properties | [Resources](#resources), [Methods](#methods), [Bindings](#bindings) |

### Properties

#### Resources

A list of resources the grant applies to.

See: [Grant Resources](#grant-resources)

#### Methods

A list of methods the grant applies to.

See: [Grant Methods](#grant-methods)

#### Resolvers

A list of resolvers the grant relies on.

See: [Grant Resolvers](#grant-resolvers)

#### Bindings

A dictionary of bindings the grant applies to.

See: [Grant Bindings](#grant-bindings)

Grant Resources Include
-----------------------

| Name | Value |
| --- | --- |
| Type | Array |

See: [Grant Resources Include Items](#grant-resources-include-items)

Grant Resources Exclude
-----------------------

| Name | Value |
| --- | --- |
| Type | Array |

See: [Grant Resources Exclude Items](#grant-resources-exclude-items)

Grant Resources Items
---------------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Resources Include Items
-----------------------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Resources Exclude Items
-----------------------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Methods Items
-------------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^[Gg][Ee][Tt]$\|^[Pp][Oo][Ss][Tt]$\|^[Pp][Uu][Tt]$\|^[Dd][Ee][Ll][Ee][Tt][Ee]$` |

Grant Resolvers Items
---------------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^[A-Za-z0-9\-]+$` |

Rune Description Domain
-----------------------

The domain the rune description is associated with.

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^([a-z0-9\-]+\.[a-z0-9\-]+){1,}\.[a-z]+$` |

Expires
-------

A duration object that represents when the rune expires.

| Name | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |

### Properties

#### Years

| Name | Value |
| --- | --- |
| Type | Integer |

#### Months

| Name | Value |
| --- | --- |
| Type | Integer |

#### Weeks

| Name | Value |
| --- | --- |
| Type | Integer |

#### Days

| Name | Value |
| --- | --- |
| Type | Integer |

#### Hours

| Name | Value |
| --- | --- |
| Type | Integer |

#### Minutes

| Name | Value |
| --- | --- |
| Type | Integer |

#### Seconds

| Name | Value |
| --- | --- |
| Type | Integer |

#### Milliseconds

| Name | Value |
| --- | --- |
| Type | Integer |

#### Microseconds

| Name | Value |
| --- | --- |
| Type | Integer |

#### Nanoseconds

| Name | Value |
| --- | --- |
| Type | Integer |

Rune Description Resolvers
--------------------------

A dictionary of resolvers.

| Name | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |
| Additional Properties | false |
| Properties matching `^[A-Za-z0-9\-]+$` | [Resolver](#resolver) |

Rune Description Grants
-----------------------

An array of grants.

| Name | Value |
| --- | --- |
| Type | Array |

See: [Grant](#grant)