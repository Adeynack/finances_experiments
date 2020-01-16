package util

// StringSet is a set of strings.
type StringSet map[string]interface{}

// Put ensures the presence of `s` in the set.
func (set StringSet) Put(s string) {
	set[s] = nil
}

// Contains indicates if `s` is present in the set.
func (set StringSet) Contains(s string) (contained bool) {
	_, contained = set[s]
	return
}
