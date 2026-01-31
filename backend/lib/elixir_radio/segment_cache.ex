defmodule ElixirRadio.SegmentCache do
  @moduledoc """
  Cachex-based cache for segment files with automatic TTL and size limits.
  Prevents unbounded memory growth while maintaining performance.
  """

  @ttl_hours 2

  @doc """
  Track-keyed helpers: cache by track id and segment number so callers
  that only have `track_id` can check the cache before querying the DB.
  """
  def get_by_track(track_id, segment_num) do
    cache_key = {:track, track_id, segment_num}

    case Cachex.get(:segment_cache, cache_key) do
      {:ok, nil} -> nil
      {:ok, data} -> data
      {:error, _} -> nil
    end
  end

  @doc """
  Stores segment data in cache with TTL.
  Cachex handles automatic eviction when limit is reached.
  """
  def put_by_track(track_id, segment_num, data) do
    cache_key = {:track, track_id, segment_num}
    ttl_ms = :timer.hours(@ttl_hours)

    Cachex.put(:segment_cache, cache_key, data, ttl: ttl_ms)
  end
end
