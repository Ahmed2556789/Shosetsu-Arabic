-- {"id":4510,"ver":"1.0.0","libVer":"1.0.0","author":"Ahmed2556789","repo":"https://github.com/Ahmed2556789/Shosetsu-Arabic","dep":[]}

local baseURL = "https://cenele.com"

local function Get(url)
    return Request(
        GET,
        url,
        {
            ["User-Agent"] = "Mozilla/5.0 (Android) Shosetsu"
        }
    )
end

function GetInfo()
    return {
        name = "Cenele",
        imageURL = baseURL .. "/wp-content/uploads/2023/01/cropped-logo.png",
        baseURL = baseURL,
        lang = "ar"
    }
end

function Search(data)
    local query = data[QUERY]
    local page = data[PAGE_INDEX] or 1

    local url = baseURL .. "/?s=" .. Encode(query) .. "&paged=" .. page
    local response = Get(url)

    local novels = {}

    for item in response:gmatch('<article.-</article>') do
        local link = item:match('href="([^"]+)"')
        local title = item:match('<h%d[^>]*>.-<a[^>]*>(.-)</a>')

        if link and title then
            title = title:gsub("<.->", "")
            title = title:gsub("&amp;", "&")

            table.insert(novels, {
                title = title,
                link = link
            })
        end
    end

    return novels
end

function ParseNovel(url)
    local response = Get(url)

    local title = response:match('<h1[^>]*>(.-)</h1>')
    local cover = response:match('<img[^>]-src="([^"]+)"')

    if title then
        title = title:gsub("<.->", "")
    end

    local chapters = {}

    for link, chapter in response:gmatch('<a[^>]-href="([^"]+)"[^>]*>(.-)</a>') do
        chapter = chapter:gsub("<.->", "")

        if chapter:match("الفصل") then
            table.insert(chapters, {
                title = chapter,
                link = link
            })
        end
    end

    return {
        title = title or "Cenele",
        imageURL = cover,
        chapters = chapters
    }
end

function ParseChapter(url)
    local response = Get(url)

    local title = response:match('<h1[^>]*>(.-)</h1>')
    local content = response:match(
        '<div[^>]-class="[^"]*entry%-content[^"]*"[^>]*>(.-)</div>'
    )

    if not content then
        content = response:match(
            '<div[^>]-class="[^"]*chapter[^"]*"[^>]*>(.-)</div>'
        )
    end

    if title then
        title = title:gsub("<.->", "")
    end

    if content then
        content = content:gsub("<script.-</script>", "")
        content = content:gsub("<style.-</style>", "")
        content = content:gsub("<[^>]+>", "\n")
        content = content:gsub("&nbsp;", " ")
        content = content:gsub("&amp;", "&")
        content = content:gsub("&quot;", '"')
        content = content:gsub("&#39;", "'")
        content = content:gsub("\n%s*\n", "\n\n")
    end

    return {
        title = title or "Chapter",
        content = content or "لم يتم العثور على محتوى الفصل."
    }
end
