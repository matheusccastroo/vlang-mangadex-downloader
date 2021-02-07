import utils
import net.http
import os

fn main() {
	input_manga_ids := os.input("Enter manga ids separated by comma (,): ")
	manga_ids := utils.decompose_input(input_manga_ids, ",")

	mut manga_chapter_relation := map[string]map[string][]string{}

	// Prepare data in the type: map[string]map[string][]string{} -> that means, a map with the key as the manga_title and the value as other map that contains the chapters numbers as key and the images urls as the values.
	// manga_title: [chapter_1: [ids], chapter_2: [ids]...]
	for manga_id in manga_ids {
		manga_data := utils.do_get_request('manga/$manga_id') or {
			println('Error fetching manga with ID: $manga_id --> $err')
			continue
		}
		
		manga_title := manga_data.title
		manga_chapter_relation[manga_title] = map[string][]string{}

		chapters_data := utils.do_get_request('manga/$manga_id/chapters') or {
			println('Error fetching chapters data for $manga_title --> $err')
			continue
		}

		for chapter_data in chapters_data.chapters { // at least for now, doing this will get all chapters from all groups. We will only use the first chapter in the fn below.
			if chapter_data.language != 'gb' {continue}
			chapter_number := chapter_data.chapter
			chapter_id := chapter_data.id.str()
			manga_chapter_relation[manga_title][chapter_number] << chapter_id
		}

		for chapter, ids in manga_chapter_relation[manga_title] {
			id := ids[0]

			chapter_data := utils.do_get_request('chapter/$id') or {
				println('Error fetching chapter with ID $id --> $err')
				continue
			}

			hash := chapter_data.hash
			server_fallback := chapter_data.server_fallback
			mut chapter_images_urls := []string{}
			for image_name in chapter_data.pages {
				chapter_images_urls << server_fallback + hash + '/' + image_name
			}

			manga_chapter_relation[manga_title][chapter] = &chapter_images_urls
		}
	}

	// Actually download each image in the correct directory.
	for manga_title, chapter_number in manga_chapter_relation {
		dir_name := utils.create_dir_name(manga_title)
		if !os.exists(dir_name) {
			os.mkdir(dir_name) ?
		}
		os.chdir(dir_name)
		// create subfolders for each chapter
		for chapter, images in chapter_number {
			chapter_dir_name := utils.create_dir_name(chapter)
			if !os.exists(chapter_dir_name) {
				os.mkdir(chapter_dir_name) ?
			}
			os.chdir(chapter_dir_name)
			for i := 0; i < images.len; i++ {
				http.download_file(images[i], i.str()) ?
			}
			os.chdir('..')
		}
		os.chdir('..')
	}

}