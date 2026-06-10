{ ... }:
{
  bookmarkFolder = name: bookmarks: [
    {
      inherit name;
      toolbar = true;
      bookmarks = [ { inherit name bookmarks; } ];
    }
  ];
}
