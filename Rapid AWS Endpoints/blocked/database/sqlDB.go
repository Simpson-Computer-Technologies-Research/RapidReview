package Database

import (
	"database/sql"
	"fmt"
)

// Execute command to database
func Exists(db *sql.DB, command string) bool {
	var rows, err = db.Query(command)
	if err != nil {
		return false
	}
	defer rows.Close()
	return rows.Next()
}

// Select data from the database
func Select(db *sql.DB, command string) []string {
	var (
		data string
		res  []string = []string{}
	)
	rows, err := db.Query(command)
	if err != nil {
		return res
	}
	defer rows.Close()

	// Append result to res list
	for rows.Next() {
		err := rows.Scan(&data)
		if err == nil {
			res = append(res, fmt.Sprintf(`"%v"`, data))
		}
	}
	return res
}

// Update Database value
func Update(db *sql.DB, command string) bool {
	res, err := db.Exec(command)
	if err == nil {
		count, err := res.RowsAffected()
		if err == nil {
			return count > 0
		}
	}
	return false
}

// Delete value from database
func Delete(db *sql.DB, command string) bool {
	res, err := db.Exec(command)
	if err == nil {
		count, err := res.RowsAffected()
		if err == nil {
			return count > 0
		}
	}
	return false
}
