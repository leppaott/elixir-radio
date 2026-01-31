defmodule ElixirRadio.Factory do
  @moduledoc """
  Factory for creating test data
  """

  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog.{Genre, Artist, Album, Track, Segment}

  def build(:genre) do
    %Genre{
      name: "Test Genre #{System.unique_integer([:positive])}",
      description: "A test genre",
      image_url: "https://example.com/genre.jpg"
    }
  end

  def build(:artist) do
    %Artist{
      name: "Test Artist #{System.unique_integer([:positive])}",
      bio: "A test artist",
      image_url: "https://example.com/artist.jpg"
    }
  end

  def build(:album) do
    %Album{
      title: "Test Album #{System.unique_integer([:positive])}",
      release_year: 2024,
      cover_image_url: "https://example.com/album.jpg",
      description: "A test album"
    }
  end

  def build(:track) do
    %Track{
      title: "Test Track #{System.unique_integer([:positive])}",
      track_number: 1,
      duration_seconds: 180,
      sample_duration: 120,
      upload_status: :pending
    }
  end

  def build(:segment) do
    %Segment{
      playlist_data: "#EXTM3U\n#EXT-X-VERSION:3\n",
      processing_status: :pending
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
