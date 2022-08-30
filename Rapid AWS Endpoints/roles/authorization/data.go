package Auth

// Map of the currently used tokens
var data map[string][]string = map[string][]string{}

func CheckTokenUsage(token string, user string) bool {
	// Check if the data map contains the user
	if _, ok := data[user]; !ok {
		data[user] = []string{token}
		return true
	}

	// Check if token has already been used
	for i := 0; i < len(data[user]); i++ {
		if data[user][i] == token {
			return false
		}
	}

	// Token hasn't been used before
	// Add the token and remove first token from list if it's length > 4
	data[user] = append(data[user], token)
	if len(data[user]) > 4 {
		data[user] = data[user][1:]
	}
	return true
}
