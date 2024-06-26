library(jsonlite)
library(tidyverse)

# load in current list ----

# workaround for Lisa's httr problems
h <- curl::new_handle(ssl_verifypeer = 0)
url1 <- "https://samoa.dcs.gla.ac.uk/events/rest/Event/getgroupevents/141?includeChildren=false&startDate=2018-01-01T00%3A00%3A00.000Z"
j1_file <- curl::curl_download(url1, "j1.json", handle = h)
j1 <- read_json(j1_file)

url2 <- "https://samoa.dcs.gla.ac.uk/events/rest/Event/getgroupevents/169?includeChildren=false&startDate=2018-01-01T00%3A00%3A00.000Z"
j2_file <- curl::curl_download(url2, "j2.json", handle = h)
j2 <- read_json(j2_file)

j <- c(j1, j2)

# map to a data frame ----
jdf <- purrr::map_df(j, function(x) {
  list(
    id = x$id,
    title = x$title,
    speaker_name = x$speaker,
    speaker_affiliation = x$speakerAffiliation,
    speaker_url = x$speakerUrl,
    abstract = x$description,
    start = x$startTime,
    end = x$endTime,
    Location = x$location$location,
    resources = ""
  )
})


# fix location ----
jdf <- mutate(jdf, Location = case_when(
 # start > Sys.Date() & grepl("^Coding Club", title, FALSE) ~ "[Zoom](https://uofglasgow.zoom.us/j/93838448011)",
  id >= 17305 & id < 18270 ~ "Zoom",
  id == 18270 ~ "Zoom",
  id == 18271 ~ "62 Hillhead Street, Level 6, Meeting Room",
  id == 18274 ~ "62 Hillhead Street, Level 6, Meeting Room",
  Location == 'Other/unknown' ~ "62 Hillhead Street, Level 5, Seminar Room",
  TRUE ~ Location 
))

# add resources ----
jdf <- mutate(jdf, resources = case_when(
  id == 17924 ~ "[(slides)](slides/2021-10-13_project_planning/project_planning.pdf)",
  id == 15409 ~ "[formr](https://formr.org/), [(slides)](https://osf.io/gu23h/)",
  id == 15450 ~ "[(slides)](/mms/slides/2018_10_24_Ben_Jones.pdf)",
  id == 15451 ~ "[(tutorial)](https://psyteachr.github.io/shiny-tutorials/01-first-app.html)",
  id == 15492 ~ "[LexOPS github](https://github.com/Jack-Tay/LexOPS)",
  id == 15562 ~ "[R exams](http://www.r-exams.org), [(slides)](/mms/slides/r-exams.pdf)",
  id == 15611 ~ "[Equivalence Testing for Psychological Research](https://doi.org/10.1177/2515245918770963), [Justify Your Alpha](https://psyarxiv.com/9s3y6/), [related blog post](http://daniellakens.blogspot.com/2018/12/testing-whether-observed-data-should.html)",
  id == 16267 ~ "[(slides)](https://osf.io/d3zea/)",
  id == 16547 ~ "[(slides)](/mms/slides/barr_container.pdf)",
  id == 16659 ~ "[(slides)](/mms/slides/rousselet-interactions.pdf)",
  id == 16758 ~ "[(materials)](https://osf.io/xpskm/)",
  id == 16759 ~ "[(materials)](https://osf.io/xpskm/)",
  id == 16403 ~ "[(paper)](https://doi.org/10.1177/2515245919876960)",
  id == 17134 ~ "[(slides)](/mms/slides/hyllested_generalizability_theory.pdf)",
  id == 17130L ~ "[(slides)](/mms/slides/taylor-estimating-distributional-parameters.pdf)",
  id == 17737 ~ "[(slides)](/mms/slides/UKDS_GettingMostOutofData_02-06-2021.pdf)",
  id == 17747 ~ "[(slides)](/mms/slides/rousselet-bootstrap.pdf)",
  #grepl("^Coding Club", title, FALSE) ~ "[(link)](https://psyteachr.github.io/mms/coding_club.html)",
  TRUE ~ resources
))

# delete cancelled talks ----
jdf <- filter(jdf, !id %in% c(16379L, 16229L, 15603L, 16746L, 16963L, 16933L, 17802L, 17967L, 17968L, 18030L))

# add missing  ----

jdf <- jdf %>%
  add_row(speaker_name = "Coding Club",
          speaker_url = "",
          speaker_affiliation = "",
          abstract = "",
          resources = "",
          Location = "",
          title = "**Cancelled due to strike**",
          start = "2021-12-01T14:00", 
          end = "2019-12-01T15:00") %>%
add_row(speaker_name = "M&Ms",
        speaker_url = "",
        speaker_affiliation = "",
        abstract = "",
        resources = "",
        Location = "",
        title = "**Cancelled due to strike**",
        start = "2021-12-01T16:00", 
        end = "2019-12-01T17:00") %>%
  add_row(speaker_name = "Daniël Lakens", 
          speaker_url = "https://twitter.com/lakens", 
          speaker_affiliation = "Eindhoven University of Technology",
          title = "Justify Everything (Or: Why All Norms You Rely on When Doing Research Are Wrong)", 
          resources = "[(slides)](https://osf.io/j4s3c/)",
          start = "2019-02-08T15:30", 
          end = "2019-02-08T16:30", 
          Location = "62 Hillhead Street, Level 5, Seminar Room",
          abstract = "Science is difficult. To do good science researchers need to know about philosophy of science, learn how to develop theories, become experts in experimental design, study measurement theory, understand the statistics they require to analyze their data, and clearly communicate their results. My personal goal is to become good enough in all these areas such that I will be able to complete a single flawless experiment, just before I retire – but I expect to fail. In the meantime, I often need to rely on social norms when I make choices as I perform research. From the way I phrase my research question, to how I determine the sample size for a study, or my decision for a one or two-sided test, my justifications are typically ‘this is how we do it’. If you ask me ‘why’ I often don’t know the answer. In this talk I will explain that, regrettably, almost all the norms we rely on are wrong. I will provide some suggestions for attempts to justify aspects of the research cycle that I am somewhat knowledgeable in, mainly in the area of statistics and experimental design. I will discuss the (im)possibility of individually accumulating sufficient knowledge to actually be able to justify all important decisions in the research you do, and make some tentative predictions that in half a century most scientific disciplines will have become massively more collaborative, with a stronger task division between scholars working on joint projects.")


# check for speakers with no url
#filter(jdf, speaker_url == "") %>% select(speaker_name)

# check for speakers with no affiliation
#filter(jdf, speaker_affiliation == "") %>% select(speaker_name)


# fixes for missing info ----

glasgow_speakers <- c("Lisa DeBruine", "Dale Barr", "Ben Jones", "Benedict Jones", "Guillaume Rousselet", "Martin Lages", "Robin Ince and Guillaume Rousselet", "Maria Gardani & Satu Baylan", "Jack Taylor and Lisa DeBruine", "Dr. Jo Neary & Kathryn Machray", "Lawrence Barsalou", "Jack Taylor", "Carolyn Saund", "Robin Ince", "Anna Henschel", "Ruud Hortensius", "Maria Gardani", "Phil McAleer", "James Bartlett")


## add speaker URLs ----
jdf <- mutate(jdf, speaker_url = ifelse(speaker_url == "", case_when(
  speaker_name == "Lisa DeBruine" ~ "https://debruine.github.io",
  speaker_name == "Dale Barr" ~ "https://twitter.com/dalejbarr/",
  speaker_name == "Robin Ince" ~ "http://www.robinince.net",
  speaker_name == "Carolyn Saund" ~ "http://carolynsaund.me/",
  speaker_name == "Jack Taylor" ~ "https://twitter.com/jackedtaylor",
  speaker_name == "Lawrence Barsalou" ~ "http://barsaloulab.org",
  speaker_name == "Ben Jones" ~ "https://twitter.com/Ben_C_J",
  speaker_name == "Benedict Jones" ~ "https://twitter.com/Ben_C_J",
  speaker_name == "Christoph Schild" ~ "https://twitter.com/schildchristoph",
  speaker_name == "Martin Lages" ~ "https://www.gla.ac.uk/schools/psychology/staff/martinlages/",
  speaker_name == "Anna Henschel" ~ "https://twitter.com/AnnaHenschel",
  speaker_name == "Anne Scheel" ~ "https://twitter.com/annemscheel",
  speaker_name == "Guillaume Rousselet" ~ "https://twitter.com/robustgar",
  speaker_name == "Zoltan Dienes" ~ "http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/",
  speaker_name == "Ruud Hortensius" ~ "https://twitter.com/RuudHortensius",
  speaker_name == "Andrew Burns" ~ "https://www.gla.ac.uk/schools/socialpolitical/research/students/andrewburns/",
  speaker_name == "Lisa Kidd" ~ "https://www.gla.ac.uk/schools/medicine/staff/lisakidd/",
  speaker_name == "Georgi Karadzhov" ~ "https://twitter.com/g_karadzhov",
  speaker_name == "Alba Contreras Cuevas" ~ "https://es.linkedin.com/in/alba-contreras-cuevas-9a57a17b",
  speaker_name == "" ~ "",
  TRUE ~ speaker_url
), speaker_url)) %>%
  mutate(speaker_affiliation = case_when(
    speaker_name %in% glasgow_speakers ~ "University of Glasgow",
    TRUE ~ speaker_affiliation
  )) %>%
  mutate(Location = if_else(id %in% c(17054, 17080, 17102), "Zoom", Location))

# fix timezone ----

jdf$end <- lubridate::ymd_hm(jdf$end, tz = "UTC") %>%
  lubridate::with_tz("Europe/London")

jdf$start <- lubridate::ymd_hm(jdf$start, tz = "UTC") %>%
  lubridate::with_tz("Europe/London")


## generate schedule ----
sf <- lubridate::stamp("Wed, Jan 17, 1999")
tm <- lubridate::stamp("15:34")

schedule <- jdf %>%
  mutate(Speaker = ifelse(speaker_url == "", speaker_name, paste0("[", speaker_name, "](", speaker_url,")"))) %>%
  mutate(Speaker = paste0(Speaker, "<br>", speaker_affiliation)) %>%
  mutate(abstract = ifelse(abstract == "", "", paste0(" <button>abstract</button><div class='abstract'>",abstract, "</div>"))) %>%
  mutate(Title = paste0(title, " ", resources, " ", abstract)) %>%
  mutate(Title = gsub("\n---\n", "\n-------\n", Title, fixed = TRUE)) %>%
  #separate(start, c("Date", "start"), sep = "T") %>%
  #separate(end, c("x", "end"), sep = "T") %>%
  mutate(`Date/Time` = paste0(sf(start), "<br>", tm(start), "-", tm(end))) %>%
  mutate(Location = gsub("62 Hillhead Street, ", "", Location)) %>%
  select(Speaker, Title, `Date/Time`, Location, start) 

future <- filter(schedule, start >= Sys.Date()) %>%
  arrange(start) %>%
  select(-start)

past <- filter(schedule, start < Sys.Date()) %>%
  arrange(desc(start)) %>%
  select(-start)
