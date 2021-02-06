import net.http
import time
import sync
import os
import json

const (
	mangadex_api_url = 'https://api.mangadex.org/v2/'
	default_language = 'gb'
)

struct Manga_chapters_data {
	code int
	status string
	data string
}

fn main() {
	input_manga_ids := os.input("Enter manga ids separated by comma (,): ")
	manga_ids := decompose_input(input_manga_ids, ",")

	for manga_id in manga_ids {
		request_url := mangadex_api_url + 'manga/' + manga_id + '/chapters'
		request := http.get(request_url) ?
		
		decoded_text := json.decode(Manga_chapters_data, request.text) ?

		println(request.text)
	}

}

fn decompose_input(input_string string, separator string) []string {
	mut arguments := []string
	mut string_argument := []byte

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