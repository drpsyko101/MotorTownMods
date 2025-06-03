# How To Contribute

1. Create a fork of this repository.
2. Pull the forked repository to your local machine.
3. Make the changes to the appropriate category. For example, any vehicle modification should be made to the [vehicle manager](../Scripts/VehicleManager.lua).
4. Ensure that any input/output variable name matches the raw bindings. For example, a variable named `bIsAdmin` should be preserved during API call. However, exception can be made for variables with special characters in it (i.e. `SplineDestination[2]`). In this case, an additional parser should be set in place to translate incoming/outgoing variable name. Enums are treated as `uint8` instead of string value due to the enormous usage of enums and it would be impractical to maintain parsers for them.
5. Append the documentation if applicable. Doing this will greatly helps the average Joes, and keeping things tidy.
6. Once you have committed to your fork, create a Pull Request to this repository, along with concise description of the changes.
