defmodule Cldr.Territory.Backend do
  def define_territory_module(config) do
    module = inspect(__MODULE__)
    backend = config.backend
    config = Macro.escape(config)

    quote location: :keep, bind_quoted: [module: module, backend: backend, config: config] do
      defmodule Territory do
        alias Cldr.Locale

        @doc """
        Returns a list of available styles.

        ## Example

            iex> #{inspect __MODULE__}.available_styles()
            [:short, :standard, :variant]
        """
        @spec available_styles() :: [:short | :standard | :variant]
        def available_styles(), do: Cldr.Territory.available_styles()

        @doc """
        Returns the available territories for a given locale.

        * `locale` is any configured locale. See `#{inspect __MODULE__}.known_locale_names/0`.
          The default is `Cldr.get_locale/0`

        ## Example

            => #{inspect __MODULE__}.available_territories()
            [:"001", :"002", :"003", :"005", :"009", :"011", :"013", :"014", :"015", :"017",
            :"018", :"019", :"021", :"029", :"030", :"034", :"035", :"039", :"053", :"054",
            :"057", :"061", :"142", :"143", :"145", :"150", :"151", :"154", :"155", :"202",
            :"419", :AC, :AD, :AE, :AF, :AG, :AI, :AL, :AM, :AO, :AQ, :AR, :AS, :AT, :AU,
            :AW, :AX, :AZ, :BA, :BB, ...]

            => #{inspect __MODULE__}.available_territories("zzz")
            {:error, {Cldr.UnknownLocaleError, "The locale \"zzz\" is not known."}}

        """
        @spec available_territories(Cldr.Territory.binary_tag()) :: [atom()] | {:error, Cldr.Territory.error()}
        def available_territories(locale \\ unquote(backend).get_locale())
        def available_territories(%LanguageTag{cldr_locale_name: cldr_locale_name}) do
          available_territories(cldr_locale_name)
        end

        @doc """
        Returns a map of all known territories in a given locale.

        * `locale` is any configured locale. See `#{inspect __MODULE__}.known_locale_names/0`.
          The default is `Cldr.get_locale/0`

        ## Example

            => #{inspect __MODULE__}.known_territories()
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

            => #{inspect __MODULE__}.known_territories("zzz")
            {:error, {Cldr.UnknownLocaleError, "The locale \"zzz\" is not known."}}

        """
        @spec known_territories(Cldr.Territory.binary_tag()) :: map() | {:error, Cldr.Territory.error()}
        def known_territories(locale \\ unquote(backend).get_locale())
        def known_territories(%LanguageTag{cldr_locale_name: cldr_locale_name}) do
          known_territories(cldr_locale_name)
        end

        @doc """
        Localized string for the given territory code.
        Returns `{:ok, String.t}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `locale` is any configured locale. See `#{inspect __MODULE__}.known_locale_names/0`.
            The default is `Cldr.get_locale/0`

          * `style` is one of those returned by `#{inspect __MODULE__}.available_styles/0`.
            The current styles are `:short`, `:standard` and `:variant`.
            The default is `:standard`

        ## Example

            iex> #{inspect __MODULE__}.from_territory_code(:GB)
            {:ok, "United Kingdom"}

            iex> #{inspect __MODULE__}.from_territory_code(:GB, [style: :short])
            {:ok, "UK"}

            iex> #{inspect __MODULE__}.from_territory_code(:GB, [style: :ZZZ])
            {:error, {Cldr.UnknownStyleError, "The style :ZZZ is unknown"}}

            iex> #{inspect __MODULE__}.from_territory_code(:GB, [style: "ZZZ"])
            {:error, {Cldr.UnknownStyleError, "The style \\"ZZZ\\" is unknown"}}

            iex> #{inspect __MODULE__}.from_territory_code(:GB, [locale: "pt"])
            {:ok, "Reino Unido"}

            iex> #{inspect __MODULE__}.from_territory_code(:GB, [locale: :zzz])
            {:error, {Cldr.UnknownLocaleError, "The locale :zzz is not known."}}

            iex> #{inspect __MODULE__}.from_territory_code(:GB, [locale: "zzz"])
            {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}

        """
        @spec from_territory_code(Cldr.Territory.atom_binary_tag(), Cldr.Territory.options()) :: {:ok, binary()} | {:error, Cldr.Territory.error()}
        def from_territory_code(territory_code, options \\ [locale: unquote(backend).get_locale(), style: :standard])
        def from_territory_code(territory_code, [locale: %LanguageTag{cldr_locale_name: cldr_locale_name}]) do
          from_territory_code(territory_code, [locale: cldr_locale_name, style: :standard])
        end
        def from_territory_code(territory_code, [locale: %LanguageTag{cldr_locale_name: cldr_locale_name}, style: style]) do
          from_territory_code(territory_code, [locale: cldr_locale_name, style: style])
        end
        def from_territory_code(territory_code, [locale: locale]) do
          from_territory_code(territory_code, [locale: locale, style: :standard])
        end
        def from_territory_code(territory_code, [style: style]) do
          from_territory_code(territory_code, [locale: unquote(backend).get_locale(), style: style])
        end
        def from_territory_code(territory_code, [locale: locale, style: style]) do
          territory_code
          |> Cldr.validate_territory()
          |> validate_locale(locale)
          |> case do
              {:error, reason}         -> {:error, reason}

              {:ok, code, locale_name} -> from_territory_code(code, locale_name, style)
            end
        end

        @doc """
        The same as `from_territory_code/2`, but raises an exception if it fails.

        ## Example

            iex> #{inspect __MODULE__}.from_territory_code!(:GB)
            "United Kingdom"

            iex> #{inspect __MODULE__}.from_territory_code!(:GB, [style: :short])
            "UK"

            iex> #{inspect __MODULE__}.from_territory_code!(:GB, [locale: "pt"])
            "Reino Unido"

        """
        @spec from_territory_code!(Cldr.Territory.atom_binary_tag(), Cldr.Territory.options()) :: binary() | no_return()
        def from_territory_code!(territory_code, options \\ [locale: unquote(backend).get_locale(), style: :standard])
        def from_territory_code!(territory_code, [locale: %LanguageTag{cldr_locale_name: cldr_locale_name}]) do
          from_territory_code!(territory_code, [locale: cldr_locale_name, style: :standard])
        end
        def from_territory_code!(territory_code, [locale: %LanguageTag{cldr_locale_name: cldr_locale_name}, style: style]) do
          from_territory_code!(territory_code, [locale: cldr_locale_name, style: style])
        end
        def from_territory_code!(territory_code, [locale: locale]) do
          from_territory_code!(territory_code, [locale: locale, style: :standard])
        end
        def from_territory_code!(territory_code, [style: style]) do
          from_territory_code!(territory_code, [locale: unquote(backend).get_locale(), style: style])
        end
        def from_territory_code!(territory_code, options) do
          case from_territory_code(territory_code, options) do
            {:error, {exception, msg}} -> raise exception, msg

            {:ok, result}              -> result
          end
        end

        @doc """
        Localized string for the given `LanguageTag.t`.
        Returns `{:ok, String.t}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `style` is one of those returned by `#{inspect __MODULE__}.available_styles/0`.
            The current styles are `:short`, `:standard` and `:variant`.
            The default is `:standard`

        ## Example

            iex> #{inspect __MODULE__}.from_language_tag(Cldr.get_locale())
            {:ok, "World"}

            iex> #{inspect __MODULE__}.from_language_tag(Cldr.get_locale(), [style: :short])
            {:error, {Cldr.UnknownStyleError, "The style :short is unknown"}}

            iex> #{inspect __MODULE__}.from_language_tag(Cldr.get_locale(), [style: :ZZZ])
            {:error, {Cldr.UnknownStyleError, "The style :ZZZ is unknown"}}

            iex> #{inspect __MODULE__}.from_language_tag(Cldr.get_locale(), [style: "ZZZ"])
            {:error, {Cldr.UnknownStyleError, "The style \\"ZZZ\\" is unknown"}}

        """
        @spec from_language_tag(Cldr.Territory.tag(), Cldr.Territory.options()) :: {:ok, binary()} | {:error, Cldr.Territory.error()}
        def from_language_tag(tag, options \\ [style: :standard])
        def from_language_tag(%LanguageTag{cldr_locale_name: cldr_locale_name, territory: territory}, [style: style]) do
          from_territory_code(territory, [locale: cldr_locale_name, style: style])
        end
        def from_language_tag(tag, _options), do: {:error, {Cldr.UnknownLanguageTagError, "The tag #{inspect tag} is not a valid `LanguageTag.t`"}}

        @doc """
        The same as `from_language_tag/2`, but raises an exception if it fails.

        ## Example

            iex> #{inspect __MODULE__}.from_language_tag!(Cldr.get_locale())
            "World"

        """
        @spec from_language_tag!(Cldr.Territory.tag(), Cldr.Territory.options()) :: binary() | no_return()
        def from_language_tag!(tag, options \\ [style: :standard])
        def from_language_tag!(%LanguageTag{cldr_locale_name: cldr_locale_name, territory: territory}, [style: style]) do
          from_territory_code!(territory, [locale: cldr_locale_name, style: style])
        end
        def from_language_tag!(tag, _options), do: raise Cldr.UnknownLanguageTagError, "The tag #{inspect tag} is not a valid `LanguageTag.t`"

        @doc """
        Translate a localized string from one locale to another.
        Returns `{:ok, result}` if successful, otherwise `{:error, reason}`.

        * `to_locale` is any configured locale. See `#{inspect __MODULE__}.known_locale_names/0`.
          The default is `Cldr.get_locale/0`

        ## Example

            iex> #{inspect __MODULE__}.translate_territory("Reino Unido", "pt")
            {:ok, "UK"}

            iex> #{inspect __MODULE__}.translate_territory("United Kingdom", "en", "pt")
            {:ok, "Reino Unido"}

            iex> #{inspect __MODULE__}.translate_territory("Reino Unido", :zzz)
            {:error, {Cldr.UnknownLocaleError, "The locale :zzz is not known."}}

            iex> #{inspect __MODULE__}.translate_territory("United Kingdom", "en", "zzz")
            {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}

        """
        @spec translate_territory(binary(), Cldr.Territory.binary_tag(), Cldr.Territory.binary_tag()) :: {:ok, binary()} | {:error, Cldr.Territory.error()}
        def translate_territory(localized_string, from_locale, to_locale \\ unquote(backend).get_locale())
        def translate_territory(localized_string, %LanguageTag{cldr_locale_name: from_locale}, to_locale) do
          translate_territory(localized_string, from_locale, to_locale)
        end
        def translate_territory(localized_string, from_locale, %LanguageTag{cldr_locale_name: to_locale}) do
          translate_territory(localized_string, from_locale, to_locale)
        end

        @doc """
        The same as `translate_territory/3`, but raises an exception if it fails.

        ## Example

            iex> #{inspect __MODULE__}.translate_territory!("Reino Unido", "pt")
            "UK"

            iex> #{inspect __MODULE__}.translate_territory!("United Kingdom", "en", "pt")
            "Reino Unido"

        """
        @spec translate_territory!(binary(), Cldr.Territory.binary_tag(), Cldr.Territory.binary_tag()) :: binary() | no_return()
        def translate_territory!(localized_string, from_locale, to_locale \\ unquote(backend).get_locale())
        def translate_territory!(localized_string, %LanguageTag{cldr_locale_name: from_locale}, to_locale) do
          translate_territory(localized_string, from_locale, to_locale)
        end
        def translate_territory!(localized_string, from_locale, %LanguageTag{cldr_locale_name: to_locale}) do
          translate_territory!(localized_string, from_locale, to_locale)
        end
        def translate_territory!(localized_string, locale_from, locale_name) do
          case translate_territory(localized_string, locale_from, locale_name) do
            {:error, {exception, msg}} -> raise exception, msg

            {:ok, result}              -> result
          end
        end

        @doc """
        Translate a LanguageTag.t into a localized string from one locale to another.
        Returns `{:ok, result}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `locale` is any configured locale. See `#{inspect __MODULE__}.known_locale_names/0`.
            The default is `Cldr.get_locale/0`

          * `style` is one of those returned by `#{inspect __MODULE__}.available_styles/0`.
            The current styles are `:short`, `:standard` and `:variant`.
            The default is `:standard`

        ## Example

            iex> #{inspect __MODULE__}.translate_language_tag(Cldr.get_locale())
            {:ok, "World"}

            iex> #{inspect __MODULE__}.translate_language_tag(Cldr.get_locale(), [locale: Cldr.Locale.new!("pt", TestBackend.Cldr)])
            {:ok, "Mundo"}

        """
        @spec translate_language_tag(Cldr.Territory.tag(), Cldr.Territory.options()) :: {:ok, binary()} | {:error, Cldr.Territory.error()}
        def translate_language_tag(from_locale, options \\ [locale: unquote(backend).get_locale(), style: :standard])
        def translate_language_tag(%LanguageTag{} = from_locale, [locale: %LanguageTag{} = to_locale]) do
          translate_language_tag(from_locale, [locale: to_locale, style: :standard])
        end
        def translate_language_tag(%LanguageTag{} = from_locale, [style: style]) do
          translate_language_tag(from_locale, [locale: unquote(backend).get_locale(), style: style])
        end
        def translate_language_tag(%LanguageTag{} = from_locale,  [locale: %LanguageTag{} = to_locale, style: style]) do
          case from_language_tag(from_locale, [style: style]) do
            {:error, reason} -> {:error, reason}

            {:ok, result}    -> translate_territory(result, from_locale, to_locale)
          end
        end

        def translate_language_tag(%LanguageTag{}, [locale: tag, style: _style]) do
          {:error, {Cldr.UnknownLanguageTagError, "The tag #{inspect tag} is not a valid `LanguageTag.t`"}}
        end
        def translate_language_tag(%LanguageTag{}, [locale: tag]) do
          {:error, {Cldr.UnknownLanguageTagError, "The tag #{inspect tag} is not a valid `LanguageTag.t`"}}
        end
        def translate_language_tag(tag, _options) do
          {:error, {Cldr.UnknownLanguageTagError, "The tag #{inspect tag} is not a valid `LanguageTag.t`"}}
        end

        @doc """
        The same as `translate_language_tag/2`, but raises an exception if it fails.

        ## Example

            iex> #{inspect __MODULE__}.translate_language_tag!(Cldr.get_locale())
            "World"

            iex> #{inspect __MODULE__}.translate_language_tag!(Cldr.get_locale(), [locale: Cldr.Locale.new!("pt", TestBackend.Cldr)])
            "Mundo"

        """
        @spec translate_language_tag!(Cldr.Territory.tag(), Cldr.Territory.options()) :: binary() | no_return()
        def translate_language_tag!(locale_from, options \\ [locale: unquote(backend).get_locale(), style: :standard])
        def translate_language_tag!(locale_from, options) do
          case translate_language_tag(locale_from, options) do
            {:error, {exception, msg}} -> raise exception, msg

            {:ok, result}              -> result
          end
        end

        @doc """
        Lists parent(s) for the given territory code.
        Returns `{:ok, list}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.parent(:GB)
            {:ok, [:"154", :UN]}

            iex> #{inspect __MODULE__}.parent(:ZZZ)
            {:error, {Cldr.UnknownTerritoryError, "The territory :ZZZ is unknown"}}

            iex> #{inspect __MODULE__}.parent(Cldr.get_locale())
            {:error, {Cldr.UnknownChildrenError, "The territory :\\"001\\" has no parent(s)"}}

        """
        @spec parent(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: {:ok, Cldr.Territory.atom_binary_charlist()} | {:error, Cldr.Territory.error()}
        def parent(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.parent(territory_code, opts)

        @doc """
        The same as `parent/2`, but raises an exception if it fails.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.parent!(:GB)
            [:"154", :UN]

        """
        @spec parent!(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: [Cldr.Territory.atom_binary_charlist()] | no_return()
        def parent!(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.parent!(territory_code, opts)

        @doc """
        Lists children(s) for the given territory code.
        Returns `{:ok, list}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.children(:EU)
            {:ok,
            [:AT, :BE, :CY, :CZ, :DE, :DK, :EE, :ES, :FI, :FR, :GR, :HR, :HU, :IE,
              :IT, :LT, :LU, :LV, :MT, :NL, :PL, :PT, :SE, :SI, :SK, :BG, :RO]}

            iex> #{inspect __MODULE__}.children(:ZZZ)
            {:error, {Cldr.UnknownTerritoryError, "The territory :ZZZ is unknown"}}

            iex> #{inspect __MODULE__}.children(:GB)
            {:error, {Cldr.UnknownParentError, "The territory :GB has no children"}}

        """
        @spec children(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: {:ok, Cldr.Territory.atom_binary_charlist()} | {:error, Cldr.Territory.error()}
        def children(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.children(territory_code, opts)


        @doc """
        The same as `children/2`, but raises an exception if it fails.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.children!(:EU)
            [:AT, :BE, :CY, :CZ, :DE, :DK, :EE, :ES, :FI, :FR, :GR, :HR, :HU, :IE, :IT,
            :LT, :LU, :LV, :MT, :NL, :PL, :PT, :SE, :SI, :SK, :BG, :RO]

        """
        @spec children!(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: [Cldr.Territory.atom_binary_charlist()] | no_return()
        def children!(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.children!(territory_code, opts)

        @doc """
        Checks relationship between two territories, where the first argument is the `parent` and second the `child`.
        Returns `true` if successful, otherwise `false`.

        ## Example

            iex> #{inspect __MODULE__}.contains?(:EU, :DK)
            true

            iex> #{inspect __MODULE__}.contains?(:DK, :EU)
            false

        """
        @spec contains?(Cldr.Territory.atom_tag(), Cldr.Territory.atom_tag()) :: boolean()
        def contains?(parent, child), do: Cldr.Territory.contains?(parent, child)

        @doc """
        Maps territory info for the given territory code.
        Returns `{:ok, map}` if successful, otherwise `{:error, reason}`.

        ## Example

            iex> #{inspect __MODULE__}.info(:GB)
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
        @spec info(Cldr.Territory.atom_tag()) :: {:ok, map()} | {:error, Cldr.Territory.error()}
        def info(territory_code), do: Cldr.Territory.info(territory_code)


        @doc """
        The same as `info/1`, but raises an exception if it fails.

        ## Example

            iex> #{inspect __MODULE__}.info!(:GB)
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
        @spec info!(Cldr.Territory.atom_tag()) :: map() | no_return()
        def info!(territory_code), do: Cldr.Territory.info!(territory_code)


        # Generate the functions that encapsulate the territory data from CDLR
        for locale_name <- Cldr.Config.known_locale_names(config) do
          territories = locale_name |> Cldr.Config.get_locale(config) |> Map.get(:territories)

          def available_territories(unquote(locale_name)) do
            unquote(Map.keys(territories)) |> Enum.sort()
          end

          def known_territories(unquote(locale_name)) do
            unquote(Macro.escape(territories))
          end

          @doc false
          def from_territory_code(territory_code, unquote(locale_name), style) do
            unquote(Macro.escape(territories))
            |> get_in([territory_code, style])
            |> case do
                nil    -> {:error, {Cldr.UnknownStyleError, "The style #{inspect style} is unknown"}}

                string -> {:ok, string}
              end
          end

          def translate_territory(localized_string, locale_from, unquote(locale_name)) do
            locale_from
            |> Cldr.validate_locale(unquote(backend))
            |> case do
                {:error, reason} -> {:error, reason}

                {:ok, %LanguageTag{cldr_locale_name: locale}} ->
                  {code, style} = locale
                                  |> Cldr.Config.get_locale(unquote(backend))
                                  |> Map.get(:territories)
                                  |> Enum.flat_map(fn {code, map} -> for {style, string} when string == localized_string <- map, do: {code, style} end)
                                  |> Kernel.hd()


                  {:ok, (unquote(Macro.escape(territories))[code][style])}
              end
          end
        end

        def available_territories(locale), do: {:error, Locale.locale_error(locale)}

        def known_territories(locale), do: {:error, Locale.locale_error(locale)}

        def translate_territory(_localized_string, _from, locale), do: {:error, Locale.locale_error(locale)}

        defp validate_locale({:error, reason}, _locale), do: {:error, reason}
        defp validate_locale({:ok, code}, locale) do
          locale
          |> Cldr.validate_locale(unquote(backend))
          |> case do
              {:error, error}                                    -> {:error, error}

              {:ok, %LanguageTag{cldr_locale_name: locale_name}} -> {:ok, code, locale_name}
            end
        end


        @doc """
        Unicode flag for the given territory code.
        Returns `{:ok, flag}` if successful, otherwise `{:error, reason}`.

        ## Example

            iex> #{inspect __MODULE__}.to_unicode_flag(:US)
            {:ok, "🇺🇸"}

            iex> #{inspect __MODULE__}.to_unicode_flag(:EZ)
            {:error, {Cldr.UnknownFlagError, "The territory :EZ has no flag"}}

        """
        @spec to_unicode_flag(Cldr.Territory.atom_binary_tag() | {:ok, atom()} | {:error, Cldr.Territory.error()}) :: {:ok, binary()} | {:error, Cldr.Territory.error()}
        def to_unicode_flag(territory_code), do: Cldr.Territory.to_unicode_flag(territory_code)

        @doc """
        The same as `to_unicode_flag/1`, but raises an exception if it fails.

        ## Example

            iex> #{inspect __MODULE__}.to_unicode_flag!(:US)
            "🇺🇸"

        """
        @spec to_unicode_flag!(Cldr.Territory.atom_binary_tag()) :: binary() | no_return()
        def to_unicode_flag!(territory_code), do: Cldr.Territory.to_unicode_flag!(territory_code)

        @doc """
        A helper method to get a territory's currency code
        if a territory has multiply currencies then the oldest active currency is returned.
        Returns `{:ok, code}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.to_currency_code(:US)
            {:ok, :USD}

            iex> #{inspect __MODULE__}.to_currency_code("cu")
            {:ok, :CUP}

        """
        @spec to_currency_code(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: {:ok, Cldr.Territory.atom_binary_charlist()} | {:error, Cldr.Territory.error()}
        def to_currency_code(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.to_currency_code(territory_code, opts)

        @doc """
        The same as `to_currency_code/2`, but raises an exception if it fails.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.to_currency_code!(:US)
            :USD

            iex> #{inspect __MODULE__}.to_currency_code!(:US, as: :charlist)
            'USD'

            iex> #{inspect __MODULE__}.to_currency_code!("PS")
            :ILS

            iex> #{inspect __MODULE__}.to_currency_code!("PS", as: :binary)
            "ILS"

        """
        @spec to_currency_code!(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: Cldr.Territory.atom_binary_charlist() | no_return()
        def to_currency_code!(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.to_currency_code!(territory_code, opts)


        @doc """
        A helper method to get a territory's currency codes.
        Returns `{:ok, list}` if successful, otherwise `{:error, reason}`.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.to_currency_codes(:US)
            {:ok, [:USD]}

            iex> #{inspect __MODULE__}.to_currency_codes("cu")
            {:ok, [:CUP, :CUC]}

        """
        @spec to_currency_codes(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: {:ok, [Cldr.Territory.atom_binary_charlist()]} | {:error, Cldr.Territory.error()}
        def to_currency_codes(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.to_currency_codes(territory_code, opts)

        @doc """
        The same as `to_currency_codes/2`, but raises an exception if it fails.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            iex> #{inspect __MODULE__}.to_currency_codes!(:US)
            [:USD]

            iex> #{inspect __MODULE__}.to_currency_codes!(:US, as: :charlist)
            ['USD']

            iex> #{inspect __MODULE__}.to_currency_codes!("PS")
            [:ILS, :JOD]

            iex> #{inspect __MODULE__}.to_currency_codes!("PS", as: :binary)
            ["ILS", "JOD"]

        """
        @spec to_currency_codes!(Cldr.Territory.atom_binary_tag(), Cldr.Territory.as_options()) :: [Cldr.Territory.atom_binary_charlist()] | no_return()
        def to_currency_codes!(territory_code, opts \\ [as: :atom]), do: Cldr.Territory.to_currency_codes!(territory_code, opts)

        @doc """
        Returns a list of country codes.

        * `options` are:
          * `as: :atom`
          * `as: :binary`
          * `as: :charlist`

        ## Example

            => #{inspect __MODULE__}.country_codes()
            [:AD, :AE, :AF, :AG, :AI, :AL, :AM, :AO, :AR, :AS, :AT, :AU, :AW,
            :AX, :AZ, :BA, :BB, :BD, :BE, :BF, :BG, :BH, :BI, :BJ, :BL, :BM,
            :BN, :BO, :BQ, :BR, :BS, :BT, :BV, :BW, :BY, :BZ, :CA, :CC, :CD,
            :CF, :CG, :CH, :CI, :CK, :CL, :CM, :CN, :CO, :CR, :CU, ...]

        """
        @spec country_codes(Cldr.Territory.as_options()) :: [Cldr.Territory.atom_binary_charlist()]
        def country_codes(opts \\ [as: :atom]), do: Cldr.Territory.country_codes(opts)

      end
    end
  end
end
