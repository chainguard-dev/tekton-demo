import (
    "encoding/json"
    "strings"
)
#Predicate: {
    Data: string
    Timestamp: string
    ...
}
predicate: #Predicate & {
    Data: string
    jsonData: {...} & json.Unmarshal(Data) & {
      predicateType: "gitsign.sigstore.dev/predicate/git/v0.1"
    }
}
