package util

// MapStringToStringSet is a map with string keys and string set values.
type MapStringToStringSet map[string]StringSet

// Put ensures the presence of a value in the set represented by the key.
func (m MapStringToStringSet) Put(key string, value string) {
	set, ok := m[key]
	if !ok {
		set = make(StringSet)
		m[key] = set
	}
	set.Put(value)
}
