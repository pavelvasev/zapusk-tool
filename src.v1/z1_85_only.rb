# aim: implement the `--only` logic to run only subset of components

module DasOnly

  # also has a representative in z1_20_args.rb
  
  attr_accessor :only  # string?
  
  def perform_component( component )
    if only
      #if File.fnmatch( only, component[:name], File::FNM_EXTGLOB ) -- sux.. \*autoge\* expands in bash!
      if !component["name"].index(only).nil?
        super
      else
        log "perform_component: skipped due to not matching --only filter. only=#{only}, name=#{component['name']}"
        :skipped_due_to_only_filter
      end
    else
      super
    end
  end

  # идея - что не надо удалять все состояние запуск-программы,
  # если по факту пришел запрос только на какую-то компоненту
  def move_collapsed_self_state_dir
    if only
      return :do_not_collapse_self_if_only_is_set
    end
    super
  end

end

Zapusk.prepend DasOnly
