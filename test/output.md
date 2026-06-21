Rune Description
================

A rune description describes the authorization grants for a domain.

|  |  |
| --- | --- |
| **Type** | Object |
| **Required Properties** | domain, expires, identity, grants |
| **Additional Properties** | false |

### Properties

#### Domain

The domain the rune description is associated with.

See: [Rune Description Domain](#/$defs/RuneDescriptionDomain)

#### Expires

A duration object that represents when the rune expires.

See: [Expires](#/$defs/expires)

#### Identity

The identity the rune is associated with.

|  |  |
| --- | --- |
| **Type** | String |

#### Resolvers

A dictionary of resolvers.

See: [Rune Description Resolvers](#/$defs/RuneDescriptionResolvers)

#### Grants

An array of grants.

See: [Rune Description Grants](#/$defs/RuneDescriptionGrants)

Action
------

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

|  |  |
| --- | --- |
| **Type** | Object |
| **Any Of** | Must match at least one of:<br>• [Action Any Of0](#/$defs/ActionAnyOf0)<br>• [Action Any Of1](#/$defs/ActionAnyOf1)<br>• [Action Any Of2](#/$defs/ActionAnyOf2) |

### Properties

#### Name

The name of the rule action.

|  |  |
| --- | --- |
| **Type** | String |

#### Value

The operand for the action, if any.

|  |  |
| --- | --- |
| **Type** | String, Object, or Array |

#### Action

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

See: [Action](#/$defs/action)

Action Any Of0
--------------

|  |  |
| --- | --- |
| **Required Properties** | name, value |

Action Any Of1
--------------

|  |  |
| --- | --- |
| **Required Properties** | name, action |

Action Any Of2
--------------

|  |  |
| --- | --- |
| **Required Properties** | name |

Grant Resources
---------------

A list of resources the grant applies to.

|  |  |
| --- | --- |
| **Type** | Object or Array |
| **Max Properties** | 1 |
| **Additional Properties** | false |

See: [Grant Resources Items](#/$defs/GrantResourcesItems)

### Properties

#### Include

See: [Grant Resources Include](#/$defs/GrantResourcesInclude)

#### Exclude

See: [Grant Resources Exclude](#/$defs/GrantResourcesExclude)

Grant Methods
-------------

A list of methods the grant applies to.

|  |  |
| --- | --- |
| **Type** | Array |

See: [Grant Methods Items](#/$defs/GrantMethodsItems)

Grant Resolvers
---------------

A list of resolvers the grant relies on.

|  |  |
| --- | --- |
| **Type** | Array |

See: [Grant Resolvers Items](#/$defs/GrantResolversItems)

Grant Bindings
--------------

A dictionary of bindings the grant applies to.

|  |  |
| --- | --- |
| **Type** | Object |
| **Min Properties** | 1 |
| **Additional Properties** | false |
| **`^[A-Za-z0-9_]+$`** | Type: String |

Resolver
--------

A resolver consists of an action.

|  |  |
| --- | --- |
| **Type** | Object |
| **Required Properties** | action |

### Properties

#### Action

A named policy action, whose operand may may be obtained either by specifying the value directly or an action to obtain it.

See: [Action](#/$defs/action)

Grant
-----

A grant consists of a list of resources, methods, resolvers, and bindings. It describes which methods and bindings are authorized for a list of resources.

|  |  |
| --- | --- |
| **Type** | Object |
| **Required Properties** | resources, methods, bindings |

### Properties

#### Resources

A list of resources the grant applies to.

See: [Grant Resources](#/$defs/GrantResources)

#### Methods

A list of methods the grant applies to.

See: [Grant Methods](#/$defs/GrantMethods)

#### Resolvers

A list of resolvers the grant relies on.

See: [Grant Resolvers](#/$defs/GrantResolvers)

#### Bindings

A dictionary of bindings the grant applies to.

See: [Grant Bindings](#/$defs/GrantBindings)

Grant Resources Include
-----------------------

|  |  |
| --- | --- |
| **Type** | Array |

See: [Grant Resources Include Items](#/$defs/GrantResourcesIncludeItems)

Grant Resources Exclude
-----------------------

|  |  |
| --- | --- |
| **Type** | Array |

See: [Grant Resources Exclude Items](#/$defs/GrantResourcesExcludeItems)

Grant Resources Items
---------------------

|  |  |
| --- | --- |
| **Type** | String |
| **Pattern** | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Resources Include Items
-----------------------------

|  |  |
| --- | --- |
| **Type** | String |
| **Pattern** | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Resources Exclude Items
-----------------------------

|  |  |
| --- | --- |
| **Type** | String |
| **Pattern** | `^(([A-Za-z0-9\-])([ ]{0,1}))+$` |

Grant Methods Items
-------------------

|  |  |
| --- | --- |
| **Type** | String |
| **Pattern** | `^[Gg][Ee][Tt]$\|^[Pp][Oo][Ss][Tt]$\|^[Pp][Uu][Tt]$\|^[Dd][Ee][Ll][Ee][Tt][Ee]$` |

Grant Resolvers Items
---------------------

|  |  |
| --- | --- |
| **Type** | String |
| **Pattern** | `^[A-Za-z0-9\-]+$` |

Rune Description Domain
-----------------------

The domain the rune description is associated with.

|  |  |
| --- | --- |
| **Type** | String |
| **Pattern** | `^([a-z0-9\-]+\.[a-z0-9\-]+){1,}\.[a-z]+$` |

Expires
-------

A duration object that represents when the rune expires.

|  |  |
| --- | --- |
| **Type** | Object |
| **Min Properties** | 1 |

### Properties

#### Years

|  |  |
| --- | --- |
| **Type** | Integer |

#### Months

|  |  |
| --- | --- |
| **Type** | Integer |

#### Weeks

|  |  |
| --- | --- |
| **Type** | Integer |

#### Days

|  |  |
| --- | --- |
| **Type** | Integer |

#### Hours

|  |  |
| --- | --- |
| **Type** | Integer |

#### Minutes

|  |  |
| --- | --- |
| **Type** | Integer |

#### Seconds

|  |  |
| --- | --- |
| **Type** | Integer |

#### Milliseconds

|  |  |
| --- | --- |
| **Type** | Integer |

#### Microseconds

|  |  |
| --- | --- |
| **Type** | Integer |

#### Nanoseconds

|  |  |
| --- | --- |
| **Type** | Integer |

Rune Description Resolvers
--------------------------

A dictionary of resolvers.

|  |  |
| --- | --- |
| **Type** | Object |
| **Min Properties** | 1 |
| **Additional Properties** | false |
| **`^[A-Za-z0-9\-]+$`** | [Resolver](#/$defs/resolver) |

Rune Description Grants
-----------------------

An array of grants.

|  |  |
| --- | --- |
| **Type** | Array |

See: [Grant](#/$defs/grant)