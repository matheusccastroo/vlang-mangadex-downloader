module utils

// Anonymous structs are not supported yet, so this is a workaround.
// Yeah, for some reason I need to declare the field public where I use and where I declare it. No idea.
pub struct Data {
	pub:
		chapters []Data
		title string
		main_cover string [json: mainCover]
		id int
		hash string
		volume string
		chapter string
		pages []string
		server string
		server_fallback string [json: serverFallback]
		language string
}

pub struct Request {
	code int
	status string
	message string
	pub:
		data Data
}