module utils

import net.http
import json

const (
	mangadex_api_url_v2 = 'https://api.mangadex.org/v2/'
)

pub fn decompose_input(input_string string, separator string) []string {
	mut arguments := []string{}
	mut string_argument := []byte{}

	for index,letter in input_string {
	
		if letter == separator[0] {
			arguments << string(string_argument)
			string_argument = []
			continue
		}

		string_argument << letter

		if index == input_string.len - 1 {
			arguments << string(string_argument)
		}
	}

	return arguments
}

pub fn create_dir_name(manga_title string) string {
	mut dir_name := []byte{}

	for i := 0; i < manga_title.len; i++ {
		current_char := manga_title[i]
		if current_char == ' '[0] {
			dir_name << '_'[0]
			continue
		}
		if current_char == '-'[0] || current_char == '/'[0] {
			continue
			}
		dir_name << current_char
	}

	return string(dir_name)
}

pub fn do_get_request(path string) ?Data {
	request := http.get('$mangadex_api_url_v2$path') ?
	decoded_response := json.decode(Request, request.text) ?

	if decoded_response.code == 200 {
		return decoded_response.data
	}

	return error(decoded_response.message)
}