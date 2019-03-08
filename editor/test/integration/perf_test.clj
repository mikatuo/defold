(ns integration.perf-test
  (:require [clojure.test :refer :all]
            [dynamo.graph :as g]
            [integration.test-util :as test-util]
            [internal.node :as in]
            [support.test-support :refer [with-clean-system]]))

(defn- gui-node [scene id]
  (let [id->node (->> (get-in (g/node-value scene :node-outline) [:children 0])
                   (tree-seq (constantly true) :children)
                   (map :node-id)
                   (map (fn [node-id] [(g/node-value node-id :id) node-id]))
                   (into {}))]
    (id->node id)))

(defn- drag-pull-outline! [scene-id node-id i]
  (g/set-property! node-id :position [i 0 0])
  (g/node-value scene-id :scene)
  (g/node-value scene-id :node-outline))

(defn- clock []
  (/ (System/nanoTime) 1000000.0))

(defmacro measure [binding & body]
  `(let [start# (clock)]
     (dotimes ~binding
       ~@body)
     (let [end# (clock)]
       (/ (- end# start#) ~(second binding)))))

(deftest gui-template-outline-perf
  (binding [in/*check-schemas* false]
    (testing "drag-pull-outline"
      (test-util/with-loaded-project
        (let [node-id (test-util/resource-node project "/gui/scene.gui")
              box (gui-node node-id "sub_scene/sub_box")]
          ;; WARM-UP
          (dotimes [i 50]
            (drag-pull-outline! node-id box i))
          (System/gc)
          ;; GO!
          (let [elapsed (measure [i 20]
                          (drag-pull-outline! node-id box i))]
            (is (< elapsed 12))))))))

(deftest load-project-perf
  (time
    (let [[system workspace project]
          (test-util/load-system-and-project-raw "/Users/erik.angelin/Documents/blossom_blast_saga")])))
    
