import mgstructs
import net.http
import os
import json
// manga_title: [chapter_1: [ids], chapter_2: [ids]...]
fn main() {
	input_manga_ids := os.input("Enter manga ids separated by comma (,): ")
	manga_ids := decompose_input(input_manga_ids, ",")

	mut manga_chapter_relation := map[string]map[string][]string{}

	// prepare data
	for manga_id in manga_ids {
		request := http.get('https://api.mangadex.org/v2/manga/' + manga_id) ?
		decoded_response := json.decode(mgstructs.Request, request.text) ?
		
		manga_title := decoded_response.data.title
		manga_chapter_relation[manga_title] = map[string][]string{}
		chapter_data_request := http.get('https://api.mangadex.org/v2/manga/' + manga_id + '/chapters') ?
		chapter_data_decoded_response := json.decode(mgstructs.Request, chapter_data_request.text) ?

		for chapter in chapter_data_decoded_response.data.chapters { // at least for now, doing this will get all chapters from all groups. We will only use the first chapter
			chapter_number := chapter.chapter
			chapter_id := chapter.id.str()
			chapter_language := chapter.language
			if chapter_language != 'gb' {continue}
			manga_chapter_relation[manga_title][chapter_number] << chapter_id
		}

		for chapter, ids in manga_chapter_relation[manga_title] {
			id := ids[0]
			chapter_request := http.get('https://api.mangadex.org/v2/chapter/' + id) ?
			chapter_request_decoded := json.decode(mgstructs.Request, chapter_request.text) ?

			hash := chapter_request_decoded.data.hash
			server_fallback := chapter_request_decoded.data.server_fallback
			mut chapter_images_urls := []string{}
			for image_name in chapter_request_decoded.data.pages {
				chapter_images_urls << server_fallback + hash + '/' + image_name
			}

			manga_chapter_relation[manga_title][chapter] = &chapter_images_urls
		}
	}

	for manga_title, chapter_number in manga_chapter_relation {
		dir_name := create_dir_name(manga_title)
		if !os.exists(dir_name) {
			os.mkdir(dir_name) ?
		}
		os.chdir(dir_name)
		// create subfolders for each chapter
		for chapter, images in chapter_number {
			chapter_dir_name := create_dir_name(chapter)
			if !os.exists(chapter_dir_name) {
				os.mkdir(chapter_dir_name) ?
			}
			os.chdir(chapter_dir_name)
			for i := 0; i < images.len; i++ {
				http.download_file(images[i], i.str()) ?
			}
			os.chdir('..')
		}
	}

}
//TODO --> create folders and subfolders on the specified path
fn decompose_input(input_string string, separator string) []string {
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

fn create_dir_name(manga_title string) string {
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