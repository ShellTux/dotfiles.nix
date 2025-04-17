use custom_debug::Debug;
use rand::{rng, seq::IteratorRandom};
use serde::Deserialize;
use std::{fmt::Display, fs};
use url::Url;

pub mod cli;

#[derive(Deserialize)]
struct GodsData {
    religions: Vec<Religion>,
}

#[derive(Deserialize, Debug)]
struct Religion {
    name: String,
    gods: Vec<God>,
}

#[derive(Deserialize, Clone, Debug)]
pub struct God {
    pub name: String,
    #[debug(format = "{}")]
    pub image_url: Url,
}

impl Display for God {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", &self.name)
    }
}

impl God {
    pub fn to_host(&self) -> String {
        let words: Vec<&str> = self.name.split_whitespace().collect();

        if words.len() == 1 {
            words[0].to_lowercase()
        } else {
            words
                .iter()
                .map(|word| {
                    let mut chars = word.chars();
                    match chars.next() {
                        None => String::new(),
                        Some(first) => {
                            first.to_uppercase().collect::<String>()
                                + &chars.as_str().to_lowercase()
                        }
                    }
                })
                .collect()
        }
    }
}

pub struct GodsRepository {
    data: GodsData,
}

impl Default for GodsRepository {
    fn default() -> Self {
        let json_str = include_str!("gods_data.json");

        Self {
            data: serde_json::from_str(&json_str).unwrap(),
        }
    }
}

impl GodsRepository {
    // Load data from a JSON file
    pub fn new(file_path: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let json_str = fs::read_to_string(file_path)?;
        let data: GodsData = serde_json::from_str(&json_str)?;
        Ok(Self { data })
    }

    // Retrieve a random god from all religions
    pub fn get_random_god(&self) -> Option<God> {
        let mut rng = rng();

        // Pick a random god
        self.data
            .religions
            .iter()
            .flat_map(|religion| &religion.gods)
            .choose(&mut rng)
            .cloned()
    }
}
