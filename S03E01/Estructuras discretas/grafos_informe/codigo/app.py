
import geopandas as gpd
import networkx as nx
import pandas as pd
from haversine import haversine, Unit

import os, time, pickle

import folium
import streamlit as st
from streamlit_folium import st_folium

# Shape: 
#   (920, 14)
# Structure:
#   id, stop_id, stop_code, stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url, location_type, parent_station, stop_timezone, wheelchair_boarding, geometry
DATA_PATH = os.path.join(os.getcwd(), "data\\paraderos.geojson")

def read_data():
    geojson = gpd.read_file(DATA_PATH, encoding='utf-8')
    # Clean data
    geojson = geojson[geojson["id"].notna()] # Avoid NaN values on ids

    G = nx.Graph() # G[x] -> ( (p1,p2), dist )
    try:
        G = pickle.load(open('graph.pickle', 'rb'))
        return G, geojson.geometry.values
    except:
        pass
    
    for i in range(len(geojson.geometry.values)):
        for j in range(i + 1, len(geojson.geometry.values)):
            G.add_edge(
                (geojson.geometry.values[i].y, geojson.geometry.values[i].x),
                (geojson.geometry.values[j].y, geojson.geometry.values[j].x), 
                weight = haversine(
                    (geojson.geometry.values[i].y, geojson.geometry.values[i].x), 
                    (geojson.geometry.values[j].y, geojson.geometry.values[j].x), 
                    Unit.KILOMETERS
                )
            )
    pickle.dump(G, open('graph.pickle', 'wb'))            
    return G, geojson.geometry.values

def display_data(stops, t_prim, t_kruskal, prim_time, kruskal_time):
    # Start map
    prim_map = folium.Map(location=[-35.41727, -71.63722], zoom_start=8)
    kuskal_map = folium.Map(location=[-35.41727, -71.63722], zoom_start=8)

    # Adding points to map
    prim_markers_group = folium.FeatureGroup(name="Prim markers").add_to(prim_map)
    kruskal_markers_group = folium.FeatureGroup(name="Kruskal markers").add_to(kuskal_map)
    for stop in stops:
        prim_markers_group.add_child(folium.Marker((stop.y, stop.x)))
        kruskal_markers_group.add_child(folium.Marker((stop.y, stop.x)))
    
    # Control
    folium.LayerControl().add_to(prim_map)
    folium.LayerControl().add_to(kuskal_map)

    # Prim map
    folium.PolyLine(locations=list(t_prim.edges), color='red', weight=4).add_to(prim_map)
    folium.PolyLine(locations=list(t_kruskal.edges), color='blue', weight=4).add_to(kuskal_map)
    
    col2, col3 = st.columns(2)
    # Show maps
    with col2:
        col2_1, col2_2 = col2.columns(2)
        with col2_1:
            st.metric(label="Nodes", value=len(t_prim.nodes))
            st.metric(label="Time", value=f"{round(prim_time, 3)} s")
        with col2_2:
            st.metric(label="Edges", value=len(t_prim.edges))
            st.metric(label="Sum", value=round(t_prim.size(weight="weight"), 4))
        st.subheader("Prim")
        st_folium(prim_map, key="Prim map")
    with col3:
        col3_1, col3_2 = col3.columns(2)
        with col3_1:
            st.metric(label="Nodes", value=len(t_kruskal.nodes))
            st.metric(label="Time", value=f"{round(kruskal_time, 3)} s")
        with col3_2:
            st.metric(label="Edges", value=len(t_kruskal.edges))
            st.metric(label="Sum", value=round(t_kruskal.size(weight="weight"), 4))
        st.subheader("Kruskal")
        st_folium(kuskal_map, key="Kruskal map")

def main():
    st.set_page_config(layout = 'wide')
    st.header("Arboles de Expansión")
    start_time = time.time()

    # Read data
    st.text("Reading data...")
    G, stops = read_data()

    # Applying Prim and Kruskal
    st.text("Applying Prim and Kruskal...")
    # Prim time
    start_time_prim = time.time_ns()
    t_prim = nx.minimum_spanning_tree(G, algorithm='prim')
    end_time_prim = time.time_ns()
    # Kruskal time
    start_time_kruskal = time.time_ns()
    t_kruskal = nx.minimum_spanning_tree(G, algorithm='kruskal')
    end_time_kruskal = time.time_ns()

    display_data(
        stops,
        t_prim,
        t_kruskal,
        (end_time_prim-start_time_prim)/1_000_000_000, # Time
        (end_time_kruskal-start_time_kruskal)/1_000_000_000, # Time
    )

    end_time = time.time()
    print(f"Total time: {end_time - start_time} s")
    st.text(f"Total time: {end_time - start_time} s")

if __name__ == "__main__":
    main()