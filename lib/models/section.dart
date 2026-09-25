class Section<T> {
  const Section.loading([this.data]) : error = null, isLoading = true;
  const Section.data(T this.data) : error = null, isLoading = false;
  const Section.error(this.error, [this.data]) : isLoading = false;
  final T? data;
  final String? error;
  final bool isLoading;
}