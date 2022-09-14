//TFM_UNIR_CICD_PIPELINE_COMO_CODIGO
package main

import (
	"fmt"
	"log"
	"net/http"
)

func IndexServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "TFM UNIR")
}

func main() {
	handler := http.HandlerFunc(IndexServer)
	log.Fatal(http.ListenAndServe(":8080", handler))
}
