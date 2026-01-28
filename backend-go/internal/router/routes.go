package router

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/LambdaIITH/Dashboard/backend/internal/controller"
	"github.com/LambdaIITH/Dashboard/backend/internal/middlewares"
)

func home(c *gin.Context) {
	HTMLString := "<h1>Hello from <a href='https://iith.dev' target='_blank'>Lambda IITH</a></h1>"
	c.Writer.WriteHeader(http.StatusOK)

	c.Writer.Write([]byte(HTMLString))
}

func SetupRoutes(router *gin.Engine) {

	// Home route
	router.GET("/", home)

	// Group routes for authentication
	authGroup := router.Group("/auth")
	{
		authGroup.POST("/login", controller.LoginHandler)
		authGroup.GET("/logout", controller.LogoutHandler)
	}

	// Group routes for lost items
	lostGroup := router.Group("/lost")
	{
		lostGroup.POST("/add_item", middlewares.AuthMiddleware(), controller.AddItemHandler)
		lostGroup.GET("/all", controller.GetAllItemsHandler)
		lostGroup.GET("/item/:id", controller.GetItemByIdHandler)
		lostGroup.PUT("/edit_item", middlewares.AuthMiddleware(), controller.EditItemHandler)
		lostGroup.POST("/delete_item", middlewares.AuthMiddleware(), controller.DeleteItemHandler)
		lostGroup.GET("/search", controller.SearchItemHandler)
	}

	// Group routes for transport
	transportGroup := router.Group("/transport")
	{
		transportGroup.GET("/", middlewares.AuthMiddleware(), controller.GetBusSchedule)
		transportGroup.GET("/cityBus", middlewares.AuthMiddleware(), controller.GetCityBusSchedule)
		transportGroup.POST("/qr", middlewares.AuthMiddleware(), controller.ProcessTransaction)
		transportGroup.POST("/qr/scan", middlewares.AuthMiddleware(), controller.ScanQRCode)
		transportGroup.GET("/qr/recent", middlewares.AuthMiddleware(), controller.GetRecentTransaction)
	}

	sellGroup := router.Group("/sell")
	{
		sellGroup.POST("/add_item", controller.AddSellItemHandler)
		sellGroup.GET("/all", controller.GetAllSellItemsHandler)
		sellGroup.GET("/get_item/:id", controller.GetSellItemByIdHandler)
		sellGroup.PUT("/edit_item", controller.EditSellItemHandler)
		sellGroup.POST("/delete_item", controller.DeleteSellItemHandler)
		sellGroup.GET("/search", controller.SearchSellItemHandler)
	}

	userGroup := router.Group("/user")
	{
		userGroup.GET("/", middlewares.AuthMiddleware(), controller.User)
		userGroup.PATCH("/update", middlewares.AuthMiddleware(), controller.UpdateUser)
		userGroup.PATCH("/fcm/update", middlewares.AuthMiddleware(), controller.UpdateUserFCMToken)
	}

	// Group routes for found items
	foundGroup := router.Group("/found")
	{
		foundGroup.POST("/add_item", middlewares.AuthMiddleware(), controller.AddFoundItemHandler)
		foundGroup.GET("/all", controller.GetAllFoundItemsHandler)
		foundGroup.GET("/item/:id", controller.GetFoundItemByIdHandler)
		foundGroup.PUT("/edit_item", middlewares.AuthMiddleware(), controller.EditFoundItemHandler)
		foundGroup.POST("/delete_item", middlewares.AuthMiddleware(), controller.DeleteFoundItemHandler)
		foundGroup.GET("/search", controller.SearchFoundItemHandler)
	}

	//Group routes for timetable/calendar
	timetableGroup := router.Group("/schedule")
	{
		timetableGroup.GET("/all_courses", middlewares.AuthMiddleware(), controller.GetAllCourses)
		timetableGroup.GET("/courses", middlewares.AuthMiddleware(), controller.GetTimetable)
		timetableGroup.POST("/courses", middlewares.AuthMiddleware(), controller.PostEditTimetable)
		timetableGroup.GET("/share/:code", middlewares.AuthMiddleware(), controller.GetSharedTimetable)
		timetableGroup.POST("/share", middlewares.AuthMiddleware(), controller.PostSharedTimetable)
		timetableGroup.DELETE("/share/:code", middlewares.AuthMiddleware(), controller.DeleteSharedTimetable)
	}

	// Routes for Mess Menu
	messMenuGroup := router.Group("/mess_menu")
	{
		messMenuGroup.GET("/", controller.GetMessMenu)
		messMenuGroup.POST("/", controller.PostMessMenu)
		messMenuGroup.GET("/week", controller.GetCurrentWeekNumber)
	}

	// GET : /announcements?limit=4&offset=4
	router.GET("/announcements", controller.GetAnnouncements)
	router.Static("/announcements/images", "announcementImages/")
	router.POST("/announcements", controller.PostAnnouncement)
	router.GET("/announcements/tandc", controller.GetAnnouncementsTandC)

	cabshareGroup := router.Group("/cabshare")
	{
		cabshareGroup.GET("/me", middlewares.AuthMiddleware(), controller.CheckAuth)
		cabshareGroup.POST("/bookings", middlewares.AuthMiddleware(), controller.CreateBooking)
		cabshareGroup.PATCH("/bookings/:booking_id", middlewares.AuthMiddleware(), controller.UpdateBooking)
		cabshareGroup.GET("/me/bookings", middlewares.AuthMiddleware(), controller.UserBookings)
		cabshareGroup.GET("/me/requests", middlewares.AuthMiddleware(), controller.UserRequests)
		cabshareGroup.GET("/bookings", middlewares.AuthMiddleware(), controller.SearchBookings)
		cabshareGroup.POST("/bookings/:booking_id/request", middlewares.AuthMiddleware(), controller.RequestToJoinBooking)
		cabshareGroup.DELETE("/bookings/:booking_id/request", middlewares.AuthMiddleware(), controller.DeleteRequest)
		cabshareGroup.POST("/bookings/:booking_id/accept", middlewares.AuthMiddleware(), controller.AcceptRequest)
		cabshareGroup.POST("/bookings/:booking_id/reject", middlewares.AuthMiddleware(), controller.RejectRequest)
		cabshareGroup.DELETE("/bookings/:booking_id", middlewares.AuthMiddleware(), controller.DeleteExistingBooking)
		cabshareGroup.DELETE("/bookings/:booking_id/self", middlewares.AuthMiddleware(), controller.ExitBooking)
	}

	api := router.Group("/merch")
	{
		api.GET("/items", middlewares.AuthMiddleware(), controller.GetItems)
		api.GET("/items/:item_id", middlewares.AuthMiddleware(), controller.GetItem)
		api.POST("/order", middlewares.AuthMiddleware(), controller.CreateOrder)
		api.GET("/orders", middlewares.AuthMiddleware(), controller.GetUserOrders)
	}

	//Hostel Complaints routes
	hostelComplaintsGroup := router.Group("/hostel-complaints")
	{
		hostelComplaintsGroup.POST("/", middlewares.AuthMiddleware(), controller.CreateComplaintHandler)
		hostelComplaintsGroup.GET("/my", middlewares.AuthMiddleware(), controller.GetUserComplaintsHandler)
		hostelComplaintsGroup.GET("/:id", middlewares.AuthMiddleware(), controller.GetComplaintByIDHandler)

		//admin only
		hostelComplaintsGroup.PATCH("/:id/status", controller.AdminUpdateComplaintStatusHandler)
	}
}
