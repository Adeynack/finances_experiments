package service

import (
	"database/sql"

	log "github.com/sirupsen/logrus"
)

// Users is the service for managing users.
type Users interface {
	AuthenticateUser(email, password string) bool
	GetUserInfoAndRights(email string) *UserInfo
}

// NewUsers creates a new `Users` service.
func NewUsers(databaseService Database) Users {
	// todo #13: the configuration might ask for a dummy in-memory, for local dev and/or tests
	return &userService{
		databaseService: databaseService,

		queryGetUserByEmail: databaseService.InitQuery("GetUserByEmail", `
        	select id, display_name
        	from users
        	where email = $1
    	`),

		queryGetUserRights: databaseService.InitQuery("GetUserRights", `
			select book_id, role
			from users_rights
			where user_id = $1
			
			union
			
			select $1, 'owner'
			from books
			where owner_id = $1;
		`),
	}
}

type userService struct {
	databaseService     Database
	queryGetUserByEmail *queryInfo
	queryGetUserRights  *queryInfo
}

var _ Users = (*userService)(nil)

func (s *userService) AuthenticateUser(email, password string) bool {
	row := s.databaseService.QueryRow(s.queryGetUserByEmail, email)
	var id int
	var displayName string
	err := row.Scan(&id, &displayName)
	if err == sql.ErrNoRows {
		// no user with that email found
		return false
	}
	if err != nil {
		log.Infof("Failed to query for user. Refusing authentication. %s", err)
		return false
	}
	// todo #14 : Check the password
	// For the moment, this accepts the authentication the moment the email exists in the table.
	return true
}

func (s *userService) GetUserInfoAndRights(email string) *UserInfo {
	userInfo := &UserInfo{
		GlobalRights: make([]string, 0),
		BooksRights:  make(map[int64][]string),
	}
	userRow := s.databaseService.QueryRow(s.queryGetUserByEmail, email)
	err := userRow.Scan(&userInfo.ID, &userInfo.DisplayName)
	if err == sql.ErrNoRows {
		return nil
	}
	if err != nil {
		log.Infof("Failed to query for user. %s", err)
		return nil
	}

	rightsRows, err := s.databaseService.Query(s.queryGetUserRights, userInfo.ID)
	if err != nil {
		log.Infof("Failed to query for user's rights. %s", err)
		return nil
	}
	defer rightsRows.Close()
	for rightsRows.Next() {
		var optBookID *int64
		var role string
		err := rightsRows.Scan(&optBookID, &role)
		if err != nil {
			log.Infof("Failed to scan user rights row. Discarding row. %s", err)
			continue
		}
		if optBookID == nil {
			userInfo.GlobalRights = append(userInfo.GlobalRights, role)
		} else {
			bookID := *optBookID
			rightsForThisBook, ok := userInfo.BooksRights[bookID]
			if ok {
				rightsForThisBook = append(rightsForThisBook, role)
			} else {
				rightsForThisBook = []string{role}
			}
			userInfo.BooksRights[bookID] = rightsForThisBook
		}
	}

	return userInfo
}
