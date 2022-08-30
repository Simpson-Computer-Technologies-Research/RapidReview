package main

import (
	"aws-rapid-home/html"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(func(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
		return &events.APIGatewayProxyResponse{
			Headers:    map[string]string{"Content-Type": "text/html"},
			StatusCode: 200,
			Body:       html.Welcome(),
		}, nil
	})
}

// USE POWERSHELL
/*
$Env:GOOS = "linux"; $Env:GOARCH = "amd64"; go build .\main.go
C:\Users\Admin\go\bin\build-lambda-zip.exe -output main.zip main
*/
