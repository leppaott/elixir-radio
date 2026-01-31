defmodule ElixirRadio.SegmentCache do
  @moduledoc """
  Cachex-based cache for segment files with automatic TTL and size limits.
  Prevents unbounded memory growth while maintaining performance.
  """

  @ttl_hours 24

  @doc """
  Gets segment data from cache or returns nil if not found or expired.
  """
  def get(segment_id, segment_num) do
    cache_key = {segment_id, segment_num}

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
  def put(segment_id, segment_num, data) do
    cache_key = {segment_id, segment_num}
    ttl_ms = :timer.hours(@ttl_hours)

    Cachex.put(:segment_cache, cache_key, data, ttl: ttl_ms)
  end
end
