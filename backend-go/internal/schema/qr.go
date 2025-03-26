package schema

type TransactionRequest struct {
	TransactionId string `json:"transactionId"`
	Amount        string `json:"amount"`
	Start         string `json:"start"`
	Destination   string `json:"destination"`
}

type TransactionResponse struct {
	TransactionId string `json:"transactionId"`
	PaymentTime   string `json:"paymentTime"` // hh:mm dd/mm/yy
	TravelDate    string `json:"travelDate"`  //dd/mm/yy
	BusTiming     string `json:"busTiming"`   //hh:mm
	IsUsed        bool   `json:"isUsed"`
	Start         string `json:"start"`
	Destination   string `json:"destination"`
	Amount        string `json:"amount"`
}

type ScanQRModel struct {
	IsScanned bool `json:"isScanned"`
}
