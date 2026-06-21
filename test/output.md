Rune Description
================

A rune description describes the authorization grants for a domain.

| Property | Value |
| --- | --- |
| Type | Object |
| Required Properties | domain, expires, identity, grants |
| Additional Properties | false |

### Properties

#### Domain

The domain the rune description is associated with.

| Property | Value |
| --- | --- |
| Type | String |
| Pattern | `^([a-z0-9\-]+\.[a-z0-9\-]+){1,}\.[a-z]+$` |

#### Expires

A duration object that represents when the rune expires.

| Property | Value |
| --- | --- |
| Reference | [Expires](#/$defs/expires) |

#### Identity

The identity the rune is associated with.

| Property | Value |
| --- | --- |
| Type | String |

#### Resolvers

A dictionary of resolvers.

| Property | Value |
| --- | --- |
| Reference | [Rune Description Resolvers](#/$defs/RuneDescriptionResolvers) |

#### Grants

An array of grants.

| Property | Value |
| --- | --- |
| Type | Array |
| Items | [Grant](#/$defs/grant) |

Action
------

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

| Property | Value |
| --- | --- |
| Type | Object |
| Any Of | Must match at least one of:<br>• Required Properties: name, value<br>• Required Properties: name, action<br>• Required Properties: name |

### Properties

#### Name

The name of the rule action.

| Property | Value |
| --- | --- |
| Type | String |

#### Value

The operand for the action, if any.

| Property | Value |
| --- | --- |
| Type | String, Object, or Array |

#### Action

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

| Property | Value |
| --- | --- |
| Reference | [Action](#/$defs/action) |

Grant Resources
---------------

A list of resources the grant applies to.

| Property | Value |
| --- | --- |
| Type | Object or Array |
| Max Properties | 1 |
| Additional Properties | false |
| Items | Type: String; Pattern: `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

### Properties

#### Include

| Property | Value |
| --- | --- |
| Type | Array |
| Items | Type: String; Pattern: `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

#### Exclude

| Property | Value |
| --- | --- |
| Type | Array |
| Items | Type: String; Pattern: `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Bindings
--------------

A dictionary of bindings the grant applies to.

| Property | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |
| Additional Properties | false |

### Pattern Properties

#### `^[A-Za-z0-9_]+$`

| Property | Value |
| --- | --- |
| Type | String |

Resolver
--------

A resolver consists of an action.

| Property | Value |
| --- | --- |
| Type | Object |
| Required Properties | action |

### Properties

#### Action

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

| Property | Value |
| --- | --- |
| Reference | [Action](#/$defs/action) |

Expires
-------

A duration object that represents when the rune expires.

| Property | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |

### Properties

#### Years

| Property | Value |
| --- | --- |
| Type | Integer |

#### Months

| Property | Value |
| --- | --- |
| Type | Integer |

#### Weeks

| Property | Value |
| --- | --- |
| Type | Integer |

#### Days

| Property | Value |
| --- | --- |
| Type | Integer |

#### Hours

| Property | Value |
| --- | --- |
| Type | Integer |

#### Minutes

| Property | Value |
| --- | --- |
| Type | Integer |

#### Seconds

| Property | Value |
| --- | --- |
| Type | Integer |

#### Milliseconds

| Property | Value |
| --- | --- |
| Type | Integer |

#### Microseconds

| Property | Value |
| --- | --- |
| Type | Integer |

#### Nanoseconds

| Property | Value |
| --- | --- |
| Type | Integer |

Rune Description Resolvers
--------------------------

A dictionary of resolvers.

| Property | Value |
| --- | --- |
| Type | Object |
| Min Properties | 1 |
| Additional Properties | false |

### Pattern Properties

#### `^[A-Za-z0-9\-]+$`

A resolver consists of an action.

| Property | Value |
| --- | --- |
| Reference | [Resolver](#/$defs/resolver) |

Grant
-----

A grant consists of a list of resources, methods, resolvers, and bindings. It describes which methods and bindings are authorized for a list of resources.

| Property | Value |
| --- | --- |
| Type | Object |
| Required Properties | resources, methods, bindings |

### Properties

#### Resources

A list of resources the grant applies to.

| Property | Value |
| --- | --- |
| Reference | [Grant Resources](#/$defs/GrantResources) |

#### Methods

A list of methods the grant applies to.

| Property | Value |
| --- | --- |
| Type | Array |
| Items | Type: String; Pattern: `^[Gg][Ee][Tt]$\|^[Pp][Oo][Ss][Tt]$\|^[Pp][Uu][Tt]$\|^[Dd][Ee][Ll][Ee][Tt][Ee]$` |

#### Resolvers

A list of resolvers the grant relies on.

| Property | Value |
| --- | --- |
| Type | Array |
| Items | Type: String; Pattern: `^[A-Za-z0-9\-]+$` |

#### Bindings

A dictionary of bindings the grant applies to.

| Property | Value |
| --- | --- |
| Reference | [Grant Bindings](#/$defs/GrantBindings) |