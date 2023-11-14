// ---------
// Functions
// ---------

// TODO: Not implemented feature

@export()
func newName(name string) string => uniqueString(resourceGroup().id, name)
