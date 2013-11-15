# Uber build script for Scala IDE

> One build script to rule them all.

Build script design to unify all compound builds needed around [Scala IDE][scala-ide].
It supports rebuilding everything from source, starting from Scala all the way to the product,
as well as producing the Scala IDE release or providing CI support for the Scala pull requests
validator.

The main usages are:

* generate the Scala IDE releases (IDE, plugins and bundle), with or without publishing.
* check integration of Scala IDE and the plugins nighlty.
* perform Scala IDE builds as part of the Scala pull request validator
* rebuild Scala pr validation builds locally, to study failures
* build Scala IDE against any custom version of Scala, to test changes made to the compiler

The current build works for Scala 2.10.x and 2.11.x, and Scala IDE 4.0.x.


[scala-ide]: https://github.com/scala-ide/scala-ide/
[worksheet]: https://github.com/scala-ide/scala-worksheet/
