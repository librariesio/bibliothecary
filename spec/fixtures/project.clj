(defproject clojars-json "0.1.0"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [cheshire "5.4.0"]
                 [compojure "1.3.2"]
                 [ring/ring-defaults "0.1.2"]
                 [ring/ring-jetty-adapter "1.2.1"]]
  :plugins [[lein-ring "0.8.13"]]
  :min-lein-version "2.0.0"
  :ring {:handler clojars-json.core/app}
  :uberjar-name "clojars-json.jar"
  :profiles {:uberjar {:aot :all}}
  :main clojars-json.core
  )
