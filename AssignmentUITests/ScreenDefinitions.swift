import TABTestKit

struct ListScreen: Screen {
	let trait = Header(id: "Latest Movies")
	let movieList = Table(id: "MOVIE_LIST")

	var lastCell: Cell {
		return movieList.cell(index: movieList.numberOfCells() - 1)
	}
}

struct DetailScreen: Screen {
	let trait = Header(id: "Movie Details")
	let movieList = Table(id: "MOVIE_LIST")

	var lastCell: Cell {
		return movieList.cell(index: movieList.numberOfCells() - 1)
	}

}
