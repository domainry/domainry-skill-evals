package main

import (
	"os"

	"github.com/codeck-backend/verdent-template/pkg/runtimehost"

	"example.com/domainry/m1-sales-crm/generated/composition"
)

var runtimeVersion = "v0.0.0-source-6475ed3db452a8aa"

func main() {
	os.Exit(runtimehost.RunCommand(
		os.Args[1:],
		os.Stdout,
		os.Stderr,
		composition.RuntimeOptions(runtimeVersion),
	))
}
