(ns get-babashka-metadata
  (:require [clojure.edn :as edn]
            [clojure.java.io :as io]
            [clojure.pprint :refer [pprint]]))

(let [{:keys [data out-file]} (edn/read-string (first *command-line-args*))
      metadata {:version (System/getProperty "babashka.version")
                :data (mapv slurp data)}]
  (pprint metadata)
  (spit (io/file out-file) metadata))
