package service

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func Test_minimizeSql_MultipleSpacesAreStripped(t *testing.T) {
	source := `select    * from      users  where id=     '123asd'`
	expected := `select * from users where id= '123asd'`
	actual := minifySQL(source)
	assert.Equal(t, expected, actual)
}

func Test_minimizeSql_LineFeedsAndTabsAreStripped(t *testing.T) {
	source := `
	select *
	from users
	where
		id = '123asd'
	`
	expected := `select * from users where id = '123asd'`
	actual := minifySQL(source)
	assert.Equal(t, expected, actual)
}

func Test_minimizeSql_FrontAndTrailingSpacesAreStripped(t *testing.T) {
	source := `    select * from users where id = '123asd'    `
	expected := `select * from users where id = '123asd'`
	actual := minifySQL(source)
	assert.Equal(t, expected, actual)
}
