Rune Description
================

[Action](#action) | [Action Variation 1](#action-variation-1) | [Action Variation 2](#action-variation-2) | [Action Variation 3](#action-variation-3) | [Resources](#resources) | [Methods](#methods) | [Resolvers (Grant)](#resolvers-grant) | [Bindings](#bindings) | [Resolver](#resolver) | [Grant](#grant) | [Include](#include) | [Exclude](#exclude) | [Resources Items](#resources-items) | [Include Items](#include-items) | [Exclude Items](#exclude-items) | [Methods Items](#methods-items) | [Resolvers Items](#resolvers-items) | [Domain](#domain) | [Expires](#expires) | [Resolvers (Rune Description)](#resolvers-rune-description) | [Grants](#grants)

A rune description describes the authorization grants for a domain.

| Name | Value |
| --- | --- |
| Type | Object |
| Required Properties | [Domain](#domain), [Expires](#expires), [Identity](#identity), [Grants](#grants) |
| Additional Properties | false |

### Properties

#### Domain

The domain the rune description is associated with.

See: [Domain](#domain)

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

See: [Resolvers (Rune Description)](#resolvers-rune-description)

#### Grants

An array of grants.

See: [Grants](#grants)

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

Resources
---------

A list of resources the grant applies to.

| Name | Value |
| --- | --- |
| Type | Object or Array |
| Max Properties | 1 |
| Additional Properties | false |

See: [Resources Items](#resources-items)

### Properties

#### Include

See: [Include](#include)

#### Exclude

See: [Exclude](#exclude)

Methods
-------

A list of methods the grant applies to.

| Name | Value |
| --- | --- |
| Type | Array |

See: [Methods Items](#methods-items)

Resolvers (Grant)
-----------------

A list of resolvers the grant relies on.

| Name | Value |
| --- | --- |
| Type | Array |

See: [Resolvers Items](#resolvers-items)

Bindings
--------

A dictionary of bindings the grant applies to.

| Name | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |
| Additional Properties | false |

### Properties

#### Properties matching `^[A-Za-z0-9_]+$`

| Name | Value |
| --- | --- |
| Type | String |

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

See: [Resources](#resources)

#### Methods

A list of methods the grant applies to.

See: [Methods](#methods)

#### Resolvers

A list of resolvers the grant relies on.

See: [Resolvers (Grant)](#resolvers-grant)

#### Bindings

A dictionary of bindings the grant applies to.

See: [Bindings](#bindings)

Include
-------

| Name | Value |
| --- | --- |
| Type | Array |

See: [Include Items](#include-items)

Exclude
-------

| Name | Value |
| --- | --- |
| Type | Array |

See: [Exclude Items](#exclude-items)

Resources Items
---------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Include Items
-------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Exclude Items
-------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Methods Items
-------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^[Gg][Ee][Tt]$\|^[Pp][Oo][Ss][Tt]$\|^[Pp][Uu][Tt]$\|^[Dd][Ee][Ll][Ee][Tt][Ee]$` |

Resolvers Items
---------------

| Name | Value |
| --- | --- |
| Type | String |
| Pattern | `^[A-Za-z0-9\-]+$` |

Domain
------

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

Resolvers (Rune Description)
----------------------------

A dictionary of resolvers.

| Name | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |
| Additional Properties | false |

### Properties

#### Properties matching `^[A-Za-z0-9\-]+$`

A resolver consists of an action.

See: [Resolver](#resolver)

Grants
------

An array of grants.

| Name | Value |
| --- | --- |
| Type | Array |

See: [Grant](#grant)