```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "TimeseriesTools"
  text: "Time-series analysis in Julia"
  tagline: "A suite of tools for regular, irregular, and multivariate time series: wrangle, analyze, and visualize."
  image:
    src: /logo.png
    alt: TimeseriesTools logo.
  actions:
    - theme: brand
      text: Get started
      link: /quickstart
    - theme: alt
      text: Tutorial
      link: /TimeseriesTools/tutorial
    - theme: alt
      text: View on Github
      link: https://github.com/brendanjohnharris/TimeseriesTools.jl

features:
  - icon: 🧰
    title: TimeseriesTools
    details: The core data model plus spectra, spike trains, filtering, resampling, and imputation.
    link: /TimeseriesTools/index
  - icon: 📈
    title: TimeseriesMakie
    details: Makie recipes for series, spectra, spike rasters, and trajectories.
    link: /TimeseriesMakie/index
  - icon: ⚖️
    title: Normalization
    details: Composable, invertible normalization methods for array data.
    link: /Normalization/index
  - icon: 🗺️
    title: MoreMaps
    details: Flexible parallel map configurations for abstract and nested arrays.
    link: /MoreMaps/index
---


<p style="margin-bottom:2cm"></p>

<div class="vp-doc" style="width:80%; margin:auto">

```

## Highlights

- **Consistent data**: built on `DimensionalData.jl`, giving one type that carries values, time points, spatial coordinates, units, and metadata.
- **Leverage dispatch**: distinct types for e.g. regular, irregular, and multivariate series, facilitating generic methods.
- **Unitful**: `Unitful.jl` integration keeps frequency, power, and amplitude dimensionally consistent.
- **Analysis**: spectra and spectrograms, filtering and analytic signals, interpolation/resampling/imputation, spike trains, surrogates.
- **Plotting**: `Makie.jl` recipes for series, spectra, spike rasters, and trajectories.
- **Light by default**: extensions implement heavy analysis.


```@raw html
</div>
```
