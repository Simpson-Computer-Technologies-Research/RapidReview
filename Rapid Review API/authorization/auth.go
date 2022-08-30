package Auth

import (
	"crypto/sha256"
	"encoding/hex"
	"hash"
	"strconv"
	"time"
)

// Easy Encrypt data
func Encrypt(data string) string {
	var (
		user     string = "username"
		password string = "password"
	)
	return Encode(Encode(user) + Encode(data) + Encode(password))
}

// SHA-256 Encoder
func Encode(data string) string {
	var h hash.Hash = sha256.New()
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}

// Check if the authorization token is valid
func CheckAuthToken(authToken string, data string) bool {
	for i := -5; i <= 10; i++ {
		var (
			time  int64  = time.Now().Unix() - int64(i)
			token string = Encrypt(data + ":" + strconv.Itoa(int(time)))
		)
		if authToken == token {
			return true
		}
	}
	return false
}
