class ListFlagsController {
  int page; // At the beginning, we fetch the first 10 posts
  bool hasNextPage; // There is next page or not
  // Used to display loading indicators when _firstLoad function is running
  bool isFirstLoadRunning;
  // Used to display loading indicators when _loadMore function is running
  bool isLoadMoreRunning;

  bool isEmpty;

  ListFlagsController(
      {this.page = 1,
      this.hasNextPage = true,
      this.isFirstLoadRunning = false,
      this.isLoadMoreRunning = false,
      this.isEmpty = true});
}
