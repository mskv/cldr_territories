defmodule Cldr.Territory do
  @moduledoc """
  Supports the CLDR Territories definitions which provide the localization of many
  territories.
  """

  alias Cldr.LanguageTag

  @type as_options                 :: [as: :atom | :binary | :charlist]
  @type atom_binary_charlist       :: atom() | binary() | charlist()
  @type atom_binary_tag            :: atom() | binary() | LanguageTag.t()
  @type atom_tag                   :: atom() | LanguageTag.t()
  @type binary_tag                 :: binary() | LanguageTag.t()
  @type error                      :: {module, binary()}
  @type styles                     :: :short | :standard | :variant
  @type tag                        :: LanguageTag.t()
  @type options                    :: [{:locale, binary_tag()} | {:style, styles()}]

  @styles [:short, :standard, :variant]
  @territory_containment Cldr.Config.territory_containers()
  @territory_info Cldr.Config.territories()

  @doc """
  Returns a list of available styles.

  ## Example

      iex> Cldr.Territory.available_styles()
      [:short, :standard, :variant]
  """
  @spec available_styles() :: [styles()]
  def available_styles(), do: @styles

  @doc """
  Returns the available territories for a given locale.

  * `locale` is any configured locale. See `Cldr.known_locale_names/1`.
    The default is `Cldr.get_locale/1`

  ## Example

      => Cldr.Territory.available_territories(TestBackend.Cldr)
      [:"001", :"002", :"003", :"005", :"009", :"011", :"013", :"014", :"015", :"017",
      :"018", :"019", :"021", :"029", :"030", :"034", :"035", :"039", :"053", :"054",
      :"057", :"061", :"142", :"143", :"145", :"150", :"151", :"154", :"155", :"202",
      :"419", :AC, :AD, :AE, :AF, :AG, :AI, :AL, :AM, :AO, :AQ, :AR, :AS, :AT, :AU,
      :AW, :AX, :AZ, :BA, :BB, ...]
  """
  @spec available_territories(Cldr.backend()) :: [atom()]
  def available_territories(backend) do
    module = Module.concat(backend, Territory)
    module.available_territories()
  end

  @doc """
  Returns a map of all known territories in a given locale.

  * `locale` is any configured locale. See `Cldr.known_locale_names/1`.
    The default is `Cldr.get_locale/1`

  ## Example

      => Cldr.Territory.known_territories(TestBackend.Cldr)
      %{SN: %{standard: "Senegal"}, "061": %{standard: "Polynesia"},
      BH: %{standard: "Bahrain"}, TM: %{standard: "Turkmenistan"},
      "009": %{standard: "Oceania"}, CW: %{standard: "Curaçao"},
      FR: %{standard: "France"}, TN: %{standard: "Tunisia"},
      FI: %{standard: "Finland"}, BF: %{standard: "Burkina Faso"},
      "155": %{standard: "Western Europe"}, GL: %{standard: "Greenland"},
      VI: %{standard: "U.S. Virgin Islands"}, ZW: %{standard: "Zimbabwe"},
      AR: %{standard: "Argentina"}, SG: %{standard: "Singapore"},
      SZ: %{standard: "Swaziland"}, ID: %{standard: "Indonesia"},
      NR: %{standard: "Nauru"}, RW: %{standard: "Rwanda"},
      TR: %{standard: "Turkey"}, IS: %{standard: "Iceland"},
      ME: %{standard: "Montenegro"}, AW: %{standard: "Aruba"},
      PY: %{standard: "Paraguay"}, "145": %{standard: "Western Asia"},
      CG: %{standard: "Congo - Brazzaville", variant: "Congo (Republic)"},
      LT: %{standard: "Lithuania"}, SA: %{standard: "Saudi Arabia"},
      MZ: %{standard: "Mozambique"}, NU: %{standard: "Niue"},
      NG: %{standard: "Nigeria"}, CK: %{standard: "Cook Islands"},
      ZM: %{standard: "Zambia"}, LK: %{standard: "Sri Lanka"},
      UY: %{standard: "Uruguay"}, YE: %{standard: "Yemen"},
      "011": %{standard: "Western Africa"},
      CC: %{standard: "Cocos (Keeling) Islands"}, BY: %{standard: "Belarus"},
      IL: %{standard: "Israel"}, KY: %{standard: "Cayman Islands"},
      GN: %{standard: "Guinea"}, VN: %{standard: "Vietnam"},
      PE: %{standard: "Peru"}, HU: %{standard: "Hungary"},
      HN: %{standard: "Honduras"}, GI: %{standard: "Gibraltar"},
      "142": %{standard: "Asia"}, "029": %{...}, ...}
  """
  @spec known_territories(Cldr.backend()) :: map()
  def known_territories(backend) do
    module = Module.concat(backend, Territory)
    module.known_territories()
  end

  @doc """
  Localized string for the given territory code.
  Returns `{:ok, String.t}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `locale` is any configured locale. See `Cldr.known_locale_names/1`.
      The default is `Cldr.get_locale/1`

    * `style` is one of those returned by `Cldr.Territory.available_styles/0`.
      The current styles are `:short`, `:standard` and `:variant`.
      The default is `:standard`

  ## Example

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr)
      {:ok, "United Kingdom"}

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr, [style: :short])
      {:ok, "UK"}

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr, [style: :ZZZ])
      {:error, {Cldr.UnknownStyleError, "The style :ZZZ is unknown"}}

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr, [style: "ZZZ"])
      {:error, {Cldr.UnknownStyleError, "The style \\"ZZZ\\" is unknown"}}

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr, [locale: "pt"])
      {:ok, "Reino Unido"}

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr, [locale: :zzz])
      {:error, {Cldr.UnknownLocaleError, "The locale :zzz is not known."}}

      iex> Cldr.Territory.from_territory_code(:GB, TestBackend.Cldr, [locale: "zzz"])
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}
  """
  @spec from_territory_code(atom_binary_tag(), Cldr.backend(), options()) :: {:ok, binary()} | {:error, error()}
  def from_territory_code(territory_code, backend, options \\ [locale: Cldr.get_locale(), style: :standard]) do
    module = Module.concat(backend, Territory)
    module.from_territory_code(territory_code, options)
  end

  @doc """
  The same as `from_territory_code/2`, but raises an exception if it fails.

  ## Example

      iex> Cldr.Territory.from_territory_code!(:GB, TestBackend.Cldr)
      "United Kingdom"

      iex> Cldr.Territory.from_territory_code!(:GB, TestBackend.Cldr, [style: :short])
      "UK"

      iex> Cldr.Territory.from_territory_code!(:GB, TestBackend.Cldr, [locale: "pt"])
      "Reino Unido"
  """
  @spec from_territory_code!(atom_binary_tag(), Cldr.backend(), options()) :: binary() | no_return()
  def from_territory_code!(territory_code, backend, options \\ [locale: Cldr.get_locale(), style: :standard]) do
    module = Module.concat(backend, Territory)
    module.from_territory_code!(territory_code, options)
  end

  @doc """
  Localized string for the given `LanguageTag.t`.
  Returns `{:ok, String.t}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `style` is one of those returned by `Cldr.Territory.available_styles/0`.
      The current styles are `:short`, `:standard` and `:variant`.
      The default is `:standard`

  ## Example

      iex> Cldr.Territory.from_language_tag(Cldr.get_locale(TestBackend.Cldr), TestBackend.Cldr)
      {:ok, "World"}

      iex> Cldr.Territory.from_language_tag(Cldr.get_locale(TestBackend.Cldr), TestBackend.Cldr, [style: :short])
      {:error, {Cldr.UnknownStyleError, "The style :short is unknown"}}

      iex> Cldr.Territory.from_language_tag(Cldr.get_locale(TestBackend.Cldr), TestBackend.Cldr, [style: :ZZZ])
      {:error, {Cldr.UnknownStyleError, "The style :ZZZ is unknown"}}

      iex> Cldr.Territory.from_language_tag(Cldr.get_locale(TestBackend.Cldr), TestBackend.Cldr, [style: "ZZZ"])
      {:error, {Cldr.UnknownStyleError, "The style \\"ZZZ\\" is unknown"}}
  """
  @spec from_language_tag(tag(), Cldr.backend(), options()) :: {:ok, binary()} | {:error, error()}
  def from_language_tag(tag, backend, options \\ [style: :standard]) do
    module = Module.concat(backend, Territory)
    module.from_language_tag(tag, options)
  end

  @doc """
  The same as `from_language_tag/2`, but raises an exception if it fails.

  ## Example

      iex> Cldr.Territory.from_language_tag!(Cldr.get_locale(TestBackend.Cldr), TestBackend.Cldr)
      "World"
  """
  @spec from_language_tag!(tag(), Cldr.backend(), options()) :: binary() | no_return()
  def from_language_tag!(tag, backend, options \\ [style: :standard]) do
    module = Module.concat(backend, Territory)
    module.from_language_tag!(tag, options)
  end

  @doc """
  Translate a localized string from one locale to another.
  Returns `{:ok, result}` if successful, otherwise `{:error, reason}`.

  * `to_locale` is any configured locale. See `Cldr.known_locale_names/1`.
    The default is `Cldr.get_locale/0`

  ## Example

      iex> Cldr.Territory.translate_territory("Reino Unido", "pt", TestBackend.Cldr)
      {:ok, "UK"}

      iex> Cldr.Territory.translate_territory("United Kingdom", "en", TestBackend.Cldr, "pt")
      {:ok, "Reino Unido"}

      iex> Cldr.Territory.translate_territory("Reino Unido", :zzz, TestBackend.Cldr)
      {:error, {Cldr.UnknownLocaleError, "The locale :zzz is not known."}}

      iex> Cldr.Territory.translate_territory("United Kingdom", "en", TestBackend.Cldr, "zzz")
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}
  """
  @spec translate_territory(binary(), binary_tag(), Cldr.backend(), binary_tag()) :: {:ok, binary()} | {:error, error()}
  def translate_territory(localized_string, from_locale, backend, to_locale \\ Cldr.get_locale()) do
    module = Module.concat(backend, Territory)
    module.translate_territory(localized_string, from_locale, to_locale)
  end

  @doc """
  The same as `translate_territory/3`, but raises an exception if it fails.

  ## Example

      iex> Cldr.Territory.translate_territory!("Reino Unido", "pt", TestBackend.Cldr)
      "UK"

      iex> Cldr.Territory.translate_territory!("United Kingdom", "en", TestBackend.Cldr, "pt")
      "Reino Unido"
  """
  @spec translate_territory!(binary(), binary_tag(), Cldr.backend(), binary_tag()) :: binary() | no_return()
  def translate_territory!(localized_string, from_locale, backend, to_locale \\ Cldr.get_locale()) do
    module = Module.concat(backend, Territory)
    module.translate_territory!(localized_string, from_locale, to_locale)
  end


  @doc """
  Translate a LanguageTag.t into a localized string from one locale to another.
  Returns `{:ok, result}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `locale` is any configured locale. See `Cldr.known_locale_names/1`.
      The default is `Cldr.get_locale/0`

    * `style` is one of those returned by `Cldr.Territory.available_styles/0`.
      The current styles are `:short`, `:standard` and `:variant`.
      The default is `:standard`

  ## Example

      iex> Cldr.Territory.translate_language_tag(Cldr.get_locale(), TestBackend.Cldr)
      {:ok, "World"}

      iex> Cldr.Territory.translate_language_tag(Cldr.get_locale(), TestBackend.Cldr, [locale: Cldr.Locale.new!("pt", TestBackend.Cldr)])
      {:ok, "Mundo"}
  """
  @spec translate_language_tag(tag(), Cldr.backend(), options()) :: {:ok, binary()} | {:error, error()}
  def translate_language_tag(from_locale, backend, options \\ [locale: Cldr.get_locale(), style: :standard]) do
    module = Module.concat(backend, Territory)
    module.translate_language_tag(from_locale, options)
  end

  @doc """
  The same as `translate_language_tag/2`, but raises an exception if it fails.

  ## Example

      iex> Cldr.Territory.translate_language_tag!(Cldr.get_locale(), TestBackend.Cldr)
      "World"

      iex> Cldr.Territory.translate_language_tag!(Cldr.get_locale(), TestBackend.Cldr, [locale: Cldr.Locale.new!("pt", TestBackend.Cldr)])
      "Mundo"
  """
  @spec translate_language_tag!(tag(), Cldr.backend(), options()) :: binary() | no_return()
  def translate_language_tag!(from_locale, backend, options \\ [locale: Cldr.get_locale(), style: :standard]) do
    module = Module.concat(backend, Territory)
    module.translate_language_tag!(from_locale, options)
  end

  @children Enum.flat_map(@territory_containment, fn {_, v} -> v end)
  @doc """
  Lists parent(s) for the given territory code.
  Returns `{:ok, list}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.parent(:GB)
      {:ok, [:"154", :UN]}

      iex> Cldr.Territory.parent(:ZZZ)
      {:error, {Cldr.UnknownTerritoryError, "The territory :ZZZ is unknown"}}

      iex> Cldr.Territory.parent(Cldr.get_locale())
      {:error, {Cldr.UnknownChildrenError, "The territory :\\"001\\" has no parent(s)"}}

  """
  @spec parent(atom_binary_tag(), as_options()) :: {:ok, atom_binary_charlist()} | {:error, error()}
  def parent(territory_code, opts \\ [as: :atom])
  def parent(%LanguageTag{territory: territory_code}, opts), do: parent(territory_code, opts)
  for code <- [:UN, :EU, :EZ] do
    def parent(unquote(code), [as: :atom]),     do: {:ok, [:"001"]}
    def parent(unquote(code), [as: :binary]),   do: {:ok, ["001"]}
    def parent(unquote(code), [as: :charlist]), do: {:ok, ['001']}
  end
  def parent(territory_code, [as: :atom]) do
    territory_code
    |> Cldr.validate_territory()
    |> case do
         {:error, error} -> {:error, error}

         {:ok, code}     -> @children
                            |> Enum.member?(code)
                            |> case do
                                 false -> {:error, {Cldr.UnknownChildrenError, "The territory #{inspect code} has no parent(s)"}}

                                 true  -> {:ok, @territory_containment
                                                |> Enum.filter(fn({_parent, children}) -> Enum.member?(children, code) end)
                                                |> Enum.map(fn({parent, _children}) -> parent end)
                                                |> Enum.sort()}
                               end
       end
  end
  def parent(territory_code, [as: :binary]) do
    territory_code
    |> parent()
    |> map_binary()
  end
  def parent(territory_code, [as: :charlist]) do
    territory_code
    |> parent()
    |> map_charlist()
  end

  @doc """
  The same as `parent/2`, but raises an exception if it fails.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.parent!(:GB)
      [:"154", :UN]

  """
  @spec parent!(atom_binary_tag(), as_options()) :: [atom_binary_charlist()] | no_return()
  def parent!(territory_code, opts \\ [as: :atom])
  def parent!(%LanguageTag{territory: territory_code}, opts),  do: parent!(territory_code, opts)
  def parent!(territory_code, [as: :atom]) do
    case parent(territory_code) do
      {:error, {exception, msg}} -> raise exception, msg

      {:ok, result}              -> result
    end
  end
  def parent!(territory_code, [as: :binary]) do
    territory_code
    |> parent()
    |> map_binary!()
  end
  def parent!(territory_code, [as: :charlist]) do
    territory_code
    |> parent()
    |> map_charlist!()
  end


  @parents (for {k, _v} <- @territory_containment, do: k)
  @doc """
  Lists children(s) for the given territory code.
  Returns `{:ok, list}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.children(:EU)
      {:ok,
       [:AT, :BE, :CY, :CZ, :DE, :DK, :EE, :ES, :FI, :FR, :GR, :HR, :HU, :IE,
        :IT, :LT, :LU, :LV, :MT, :NL, :PL, :PT, :SE, :SI, :SK, :BG, :RO]}

      iex> Cldr.Territory.children(:ZZZ)
      {:error, {Cldr.UnknownTerritoryError, "The territory :ZZZ is unknown"}}

      iex> Cldr.Territory.children(:GB)
      {:error, {Cldr.UnknownParentError, "The territory :GB has no children"}}

  """
  @spec children(atom_binary_tag(), as_options()) :: {:ok, atom_binary_charlist()} | {:error, error()}
  def children(territory_code, opts \\ [as: :atom])
  def children(%LanguageTag{territory: territory_code}, opts),  do: children(territory_code, opts)
  def children(territory_code, [as: :atom]) do
    territory_code
    |> Cldr.validate_territory()
    |> case do
         {:error, error} -> {:error, error}

         {:ok, code}     -> @parents
                            |> Enum.member?(code)
                            |> case do
                                 false -> {:error, {Cldr.UnknownParentError, "The territory #{inspect code} has no children"}}

                                 true  -> {:ok, @territory_containment[code]}
                               end
       end
  end
  def children(territory_code, [as: :binary]) do
    territory_code
    |> children()
    |> map_binary()
  end
  def children(territory_code, [as: :charlist]) do
    territory_code
    |> children()
    |> map_charlist()
  end

  @doc """
  The same as `children/2`, but raises an exception if it fails.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.children!(:EU)
      [:AT, :BE, :CY, :CZ, :DE, :DK, :EE, :ES, :FI, :FR, :GR, :HR, :HU, :IE, :IT,
       :LT, :LU, :LV, :MT, :NL, :PL, :PT, :SE, :SI, :SK, :BG, :RO]

  """
  @spec children!(atom_binary_tag(), as_options()) :: [atom_binary_charlist()] | no_return()
  def children!(territory_code, opts \\ [as: :atom])
  def children!(%LanguageTag{territory: territory_code}, opts),  do: children!(territory_code, opts)
  def children!(territory_code, [as: :atom]) do
    case children(territory_code) do
      {:error, {exception, msg}} -> raise exception, msg

      {:ok, result}              -> result
    end
  end
  def children!(territory_code, [as: :binary]) do
    territory_code
    |> children()
    |> map_binary!()
  end
  def children!(territory_code, [as: :charlist]) do
    territory_code
    |> children()
    |> map_charlist!()
  end

  @doc """
  Checks relationship between two territories, where the first argument is the `parent` and second the `child`.
  Returns `true` if successful, otherwise `false`.

  ## Example

      iex> Cldr.Territory.contains?(:EU, :DK)
      true

      iex> Cldr.Territory.contains?(:DK, :EU)
      false
  """
  @spec contains?(atom_tag(), atom_tag()) :: boolean()
  def contains?(%LanguageTag{territory: parent}, child), do: contains?(parent, child)
  def contains?(parent, %LanguageTag{territory: child}), do: contains?(parent, child)
  def contains?(parent, child) do
    @parents
    |> Enum.member?(parent)
    |> case do
         false -> false

         true  -> Enum.member?(@territory_containment[parent], child)
       end
  end

  @doc """
  Maps territory info for the given territory code.
  Returns `{:ok, map}` if successful, otherwise `{:error, reason}`.

  ## Example

      iex> Cldr.Territory.info(:GB)
      {:ok,
       %{
         currency: [GBP: %{from: ~D[1694-07-27]}],
         gdp: 2925000000000,
         language_population: %{
           "bn" => %{population_percent: 0.67},
           "cy" => %{official_status: "official_regional", population_percent: 0.77},
           "de" => %{population_percent: 6},
           "el" => %{population_percent: 0.33},
           "en" => %{official_status: "official", population_percent: 99},
           "fr" => %{population_percent: 19},
           "ga" => %{official_status: "official_regional", population_percent: 0.026},
           "gd" => %{
             official_status: "official_regional",
             population_percent: 0.099,
             writing_percent: 5
           },
           "it" => %{population_percent: 0.33},
           "ks" => %{population_percent: 0.19},
           "kw" => %{population_percent: 0.0031},
           "ml" => %{population_percent: 0.035},
           "pa" => %{population_percent: 0.79},
           "sco" => %{population_percent: 2.7, writing_percent: 5},
           "syl" => %{population_percent: 0.51},
           "yi" => %{population_percent: 0.049},
           "zh-Hant" => %{population_percent: 0.54}
         },
         literacy_percent: 99,
         measurement_system: %{
           default: :uksystem,
           paper_size: :a4,
           temperature: :uksystem
         },
         population: 65105200
       }}

  """
  @spec info(atom_tag()) :: {:ok, map()} | {:error, error()}
  def info(%LanguageTag{territory: territory_code}), do: info(territory_code)
  def info(territory_code) do
    territory_code
    |> Cldr.validate_territory()
    |> case do
         {:error, reason} -> {:error, reason}

         {:ok, code}      -> {:ok, @territory_info[code]}
       end
  end

  @doc """
  The same as `info/1`, but raises an exception if it fails.

  ## Example

      iex> Cldr.Territory.info!(:GB)
      %{
        currency: [GBP: %{from: ~D[1694-07-27]}],
        gdp: 2925000000000,
        language_population: %{
          "bn" => %{population_percent: 0.67},
          "cy" => %{official_status: "official_regional", population_percent: 0.77},
          "de" => %{population_percent: 6},
          "el" => %{population_percent: 0.33},
          "en" => %{official_status: "official", population_percent: 99},
          "fr" => %{population_percent: 19},
          "ga" => %{official_status: "official_regional", population_percent: 0.026},
          "gd" => %{
            official_status: "official_regional",
            population_percent: 0.099,
            writing_percent: 5
          },
          "it" => %{population_percent: 0.33},
          "ks" => %{population_percent: 0.19},
          "kw" => %{population_percent: 0.0031},
          "ml" => %{population_percent: 0.035},
          "pa" => %{population_percent: 0.79},
          "sco" => %{population_percent: 2.7, writing_percent: 5},
          "syl" => %{population_percent: 0.51},
          "yi" => %{population_percent: 0.049},
          "zh-Hant" => %{population_percent: 0.54}
        },
        literacy_percent: 99,
        measurement_system: %{
          default: :uksystem,
          paper_size: :a4,
          temperature: :uksystem
        },
        population: 65105200
      }
  """
  @spec info!(atom_tag()) :: map() | no_return()
  def info!(%LanguageTag{territory: territory_code}), do: info!(territory_code)
  def info!(territory_code) do
    case info(territory_code) do
      {:error, {exception, msg}} -> raise exception, msg

      {:ok, result}              -> result
    end
  end

  @doc """
  Unicode flag for the given territory code.
  Returns `{:ok, flag}` if successful, otherwise `{:error, reason}`.

  ## Example

      iex> Cldr.Territory.to_unicode_flag(:US)
      {:ok, "🇺🇸"}

      iex> Cldr.Territory.to_unicode_flag(:EZ)
      {:error, {Cldr.UnknownFlagError, "The territory :EZ has no flag"}}
  """
  @spec to_unicode_flag(atom_binary_tag() | {:ok, atom()} | {:error, error()}) :: {:ok, binary()} | {:error, error()}
  def to_unicode_flag(%LanguageTag{territory: territory_code}), do: to_unicode_flag(territory_code)
  def to_unicode_flag({:error, reason}), do: {:error, reason}
  def to_unicode_flag({:ok, territory_code}) do
    case flag_exists?(territory_code) do
      false -> {:error, {Cldr.UnknownFlagError, "The territory #{inspect territory_code} has no flag"}}

      true  -> {:ok, territory_code
                     |> Atom.to_charlist()
                     |> Enum.map(&to_unicode_font/1)
                     |> List.to_string()}
    end
  end
  def to_unicode_flag(territory_code), do: territory_code |> Cldr.validate_territory() |> to_unicode_flag()


  @doc """
  The same as `to_unicode_flag/1`, but raises an exception if it fails.

  ## Example

      iex> Cldr.Territory.to_unicode_flag!(:US)
      "🇺🇸"
  """
  @spec to_unicode_flag!(atom_binary_tag()) :: binary() | no_return()
  def to_unicode_flag!(%LanguageTag{territory: territory_code}), do: to_unicode_flag!(territory_code)
  def to_unicode_flag!(territory_code) do
    case to_unicode_flag(territory_code) do
      {:error, {exception, msg}} -> raise exception, msg

      {:ok, result}              -> result
    end
  end

  # https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
  defp flag_exists?(territory_code) do
    :"001"
    |> children!()
    |> Enum.flat_map(fn c -> Enum.flat_map(children!(c), &children!/1) end)
    |> Enum.concat([:EU, :UN])
    |> Enum.member?(territory_code)
  end

  # Generates functions that returns the unicode font for A-Z
  for number <- ?A..?Z do
    defp to_unicode_font(unquote(number)), do: [127400 + unquote(number) - 3]
  end

  @doc """
  A helper method to get a territory's currency code
  if a territory has multiply currencies then the oldest active currency is returned.
  Returns `{:ok, code}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.to_currency_code(:US)
      {:ok, :USD}

      iex> Cldr.Territory.to_currency_code("cu")
      {:ok, :CUP}
  """
  @spec to_currency_code(atom_binary_tag(), as_options()) :: {:ok, atom_binary_charlist()} | {:error, error()}
  def to_currency_code(territory_code, opts \\ [as: :atom])
  def to_currency_code(%LanguageTag{territory: territory_code}, opts), do: to_currency_code(territory_code, opts)
  def to_currency_code(territory_code, [as: :atom]) do
    case info(territory_code) do
      {:error, reason} -> {:error, reason}

      {:ok, territory} -> {:ok, territory |> sort_currency() |> Kernel.hd()}
    end
  end
  def to_currency_code(territory_code, [as: :binary]) do
    territory_code
    |> to_currency_code()
    |> map_binary()
  end
  def to_currency_code(territory_code, [as: :charlist]) do
    territory_code
    |> to_currency_code()
    |> map_charlist()
  end


  @doc """
  The same as `to_currency_code/2`, but raises an exception if it fails.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.to_currency_code!(:US)
      :USD

      iex> Cldr.Territory.to_currency_code!(:US, as: :charlist)
      'USD'

      iex> Cldr.Territory.to_currency_code!("PS")
      :ILS

      iex> Cldr.Territory.to_currency_code!("PS", as: :binary)
      "ILS"
  """
  @spec to_currency_code!(atom_binary_tag(), as_options()) :: atom_binary_charlist() | no_return()
  def to_currency_code!(territory_code, opts \\ [as: :atom])
  def to_currency_code!(%LanguageTag{territory: territory_code}, opts), do: to_currency_code(territory_code, opts)
  def to_currency_code!(territory_code, [as: :atom]) do
    case to_currency_code(territory_code) do
      {:error, {exception, msg}} -> raise exception, msg

      {:ok, result}              -> result
    end
  end
  def to_currency_code!(territory_code, [as: :binary]) do
    territory_code
    |> to_currency_code()
    |> map_binary!()
  end
  def to_currency_code!(territory_code, [as: :charlist]) do
    territory_code
    |> to_currency_code()
    |> map_charlist!()
  end


  @doc """
  A helper method to get a territory's currency codes.
  Returns `{:ok, list}` if successful, otherwise `{:error, reason}`.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.to_currency_codes(:US)
      {:ok, [:USD]}

      iex> Cldr.Territory.to_currency_codes("cu")
      {:ok, [:CUP, :CUC]}
  """
  @spec to_currency_codes(atom_binary_tag(), as_options()) :: {:ok, [atom_binary_charlist()]} | {:error, error()}
  def to_currency_codes(territory_code, opts \\ [as: :atom])
  def to_currency_codes(territory_code, [as: :atom]) do
    case info(territory_code) do
      {:error, reason} -> {:error, reason}

      {:ok, territory} -> {:ok, sort_currency(territory)}
    end
  end
  def to_currency_codes(territory_code, [as: :binary]) do
    territory_code
    |> to_currency_codes()
    |> map_binary()
  end
  def to_currency_codes(territory_code, [as: :charlist]) do
    territory_code
    |> to_currency_codes()
    |> map_charlist()
  end


  @doc """
  The same as `to_currency_codes/2`, but raises an exception if it fails.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      iex> Cldr.Territory.to_currency_codes!(:US)
      [:USD]

      iex> Cldr.Territory.to_currency_codes!(:US, as: :charlist)
      ['USD']

      iex> Cldr.Territory.to_currency_codes!("PS")
      [:ILS, :JOD]

      iex> Cldr.Territory.to_currency_codes!("PS", as: :binary)
      ["ILS", "JOD"]
  """
  @spec to_currency_codes!(atom_binary_tag(), as_options()) :: [atom_binary_charlist()] | no_return()
  def to_currency_codes!(territory_code, opts \\ [as: :atom])
  def to_currency_codes!(territory_code, [as: :atom]) do
    case to_currency_codes(territory_code) do
      {:error, {exception, msg}} -> raise exception, msg

      {:ok, result}              -> result
    end
  end
  def to_currency_codes!(territory_code, [as: :binary]) do
    territory_code
    |> to_currency_codes()
    |> map_binary!()
  end
  def to_currency_codes!(territory_code, [as: :charlist]) do
    territory_code
    |> to_currency_codes()
    |> map_charlist!()
  end

  defp sort_currency(%{currency: currency}) do
    currency
    |> Enum.filter(fn {_key, meta} -> !Map.has_key?(meta, :tender) and !Map.has_key?(meta, :to) end)
    |> Enum.sort(&(elem(&1, 1).from < elem(&2, 1).from))
    |> Keyword.keys()
  end

  @regions ["005", "011", "013", "014", "015", "017",
            "018", "021", "029", "030", "034", "035",
            "039", "053", "054", "057", "061", "143",
            "145", "151", "154", "155"]

  @doc """
  Returns a list of country codes.

  * `options` are:
    * `as: :atom`
    * `as: :binary`
    * `as: :charlist`

  ## Example

      => Cldr.Territory.country_codes()
      [:AD, :AE, :AF, :AG, :AI, :AL, :AM, :AO, :AR, :AS, :AT, :AU, :AW,
       :AX, :AZ, :BA, :BB, :BD, :BE, :BF, :BG, :BH, :BI, :BJ, :BL, :BM,
       :BN, :BO, :BQ, :BR, :BS, :BT, :BV, :BW, :BY, :BZ, :CA, :CC, :CD,
       :CF, :CG, :CH, :CI, :CK, :CL, :CM, :CN, :CO, :CR, :CU, ...]
  """
  @spec country_codes(as_options()) :: [atom_binary_charlist()]
  def country_codes(opts \\ [as: :atom])
  def country_codes([as: :atom]) do
    @regions
    |> Enum.flat_map(&children!/1)
    |> Enum.sort()
  end
  def country_codes([as: :binary]), do: map_binary(country_codes())
  def country_codes([as: :charlist]), do: map_charlist(country_codes())

  defp map_binary({:error, reason}), do: {:error, reason}
  defp map_binary({:ok, result}), do: {:ok, map_binary(result)}
  defp map_binary(result) when is_list(result) do
    Enum.map(result, &to_string/1)
  end
  defp map_binary(result) when is_atom(result), do: to_string(result)

  defp map_binary!({:error, {exception, reason}}), do: raise exception, reason
  defp map_binary!({:ok, result}), do: map_binary(result)

  defp map_charlist({:error, reason}), do: {:error, reason}
  defp map_charlist({:ok, result}), do: {:ok, map_charlist(result)}
  defp map_charlist(result) when is_list(result) do
    Enum.map(result, &to_charlist/1)
  end
  defp map_charlist(result) when is_atom(result), do: to_charlist(result)

  defp map_charlist!({:error, {exception, reason}}), do: raise exception, reason
  defp map_charlist!({:ok, result}), do: map_charlist(result)
end
