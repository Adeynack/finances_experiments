package problem

import (
	"encoding/json"
	"fmt"
)

// Problem is the representation of the ProblemJSON standard
type Problem struct {
	Status   int    `json:"status"`
	Type     string `json:"type,omitempty"`
	Title    string `json:"title,omitempty"`
	Detail   string `json:"detail,omitempty"`
	Instance string `json:"instance,omitempty"`
	Cause    error  `json:"-"` // for debugging purposes only, never serialize with the JSON output
}

var _ fmt.Stringer = (*Problem)(nil)
var _ error = (*Problem)(nil)

func (p Problem) String() string {
	bytes, err := json.Marshal(p)
	if err != nil {
		panic(err)
	}
	return string(bytes)
}

func (p Problem) Error() string {
	if p.Cause == nil {
		return p.String()
	}
	return fmt.Sprintf("%s caused by: %s", p.String(), p.Error())
}
