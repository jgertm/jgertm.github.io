(ns check-filenames
  (:require [clojure.string :as string]))

(let [offending-files
      (->> *command-line-args*
           (filter (fn [file] (re-find #"\.clj[cs]?$" file)))  ; (1)
           (remove (fn [file] (re-find #"^[a-z0-9_/]+\.clj[cs]?$" file))))]  ; (2)
  (when (not-empty offending-files)
    (println (format "Files with invalid paths:\n%s"  ; (3)
               (string/join "\n" offending-files)))
    (System/exit 1)))   ; (4)
