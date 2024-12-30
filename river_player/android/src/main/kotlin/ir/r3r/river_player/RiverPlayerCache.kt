package ir.r3r.river_player

import android.content.Context
import android.util.Log
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.database.ExoDatabaseProvider
import java.io.File
import java.lang.Exception

object RiverPlayerCache {
    @Volatile
    private var instance: SimpleCache? = null
    fun createCache(context: Context, cacheFileSize: Long): SimpleCache? {
        if (instance == null) {
            synchronized(RiverPlayerCache::class.java) {
                if (instance == null) {
                    instance = SimpleCache(
                        File(context.cacheDir, "betterPlayerCache"),
                        LeastRecentlyUsedCacheEvictor(cacheFileSize),
                        ExoDatabaseProvider(context)
                    )
                }
            }
        }
        return instance
    }

    @JvmStatic
    fun releaseCache() {
        try {
            if (instance != null) {
                instance!!.release()
                instance = null
            }
        } catch (exception: Exception) {
            Log.e("BetterPlayerCache", exception.toString())
        }
    }
}