import os
import numpy as np
import pytest
from mirdata import annotations
from mirdata.datasets import compmusic_raga
from tests.test_utils import run_track_tests


def test_track():
    default_trackid = "Aruna_Sairam.Valli_Kanavan"
    data_home = os.path.normpath(
        "tests/resources/mir_datasets/compmusic_raga"
    )
    dataset = compmusic_raga.Dataset(data_home, version="test")
    track = dataset.track(default_trackid)

    expected_attributes = {
        "track_id": "Aruna_Sairam.Valli_Kanavan",
        "audio_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/audio/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.mp3",
        ),
        "tonic_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.tonic",
        ),
        "tonic_fine_tuned_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.tonicFine",
        ),
        "pitch_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.pitch",
        ),
        "pitch_post_processed_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.pitchSilIntrpPP",
        ),
        "nyas_segments_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.flatSegNyas",
        ),
        "tani_segments_path": os.path.join(
            os.path.normpath("tests/resources/mir_datasets/compmusic_raga/"),
            "RagaDataset/Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/Valli_Kanavan/",
            "Valli_Kanavan.taniSegKNN",
        ),
    }

    expected_property_types = {
        "recording": str,
        "concert": str,
        "artist": str,
        "mbid": str,
        "raga": str,
        "ragaid": str,
        "mbid": str,
        "tradition": str,
        "tonic": float,
        "tonic_fine_tuned": float,
        "pitch": annotations.F0Data,
        "pitch_post_processed": annotations.F0Data,
        "nyas_segments": annotations.EventData,
        "tani_segments": annotations.EventData,
        "audio": tuple,
    }

    run_track_tests(track, expected_attributes, expected_property_types)

    # test audio loading functions
    audio, sr = track.audio
    assert sr == 44100
    assert audio.shape[0] == 2


def test_load_tonic():
    data_home = "tests/resources/mir_datasets/compmusic_raga"
    dataset = compmusic_raga.Dataset(data_home, version="test")
    track = dataset.track("Aruna_Sairam.Valli_Kanavan")
    tonic_path = track.tonic_path
    parsed_tonic = compmusic_raga.load_tonic(tonic_path)
    assert parsed_tonic == 174.614116
    assert compmusic_raga.load_tonic(None) is None


def test_load_pitch():
    data_home = "tests/resources/mir_datasets/compmusic_raga"
    dataset = compmusic_raga.Dataset(data_home, version="test")
    track = dataset.track("Aruna_Sairam.Valli_Kanavan")
    pitch_path = track.pitch_path
    parsed_pitch = compmusic_raga.load_pitch(pitch_path)

    # Check types
    assert type(parsed_pitch) == annotations.F0Data
    assert type(parsed_pitch.times) is np.ndarray
    assert type(parsed_pitch.frequencies) is np.ndarray
    assert type(parsed_pitch.voicing) is np.ndarray

    # Check values
    assert np.array_equal(
        parsed_pitch.times,
        np.array([0.0000000, 0.0044444, 0.0088889]),
    )
    assert np.array_equal(
        parsed_pitch.frequencies,
        np.array(
            [
                290.2945557,
                0.0000000,
                290.2945557,
            ]
        ),
    )
    assert np.array_equal(parsed_pitch.voicing, np.array([1.0, 0.0, 1.0]))

    assert compmusic_raga.load_pitch(None) is None

    empty_pitch_path = (
        "tests/resources/mir_datasets/compmusic_raga/RagaDataset/"
        + "Carnatic/features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/"
        + "Valli_Kanavan/Valli_Kanavan_empty.pitch"
    )
    assert compmusic_raga.load_pitch(empty_pitch_path) is None


def test_load_segments():
    data_home = "tests/resources/mir_datasets/compmusic_raga"
    dataset = compmusic_raga.Dataset(data_home, version="test")
    track = dataset.track("Aruna_Sairam.Valli_Kanavan")
    nyas_segments_path = track.nyas_segments_path
    tani_segments_path = track.tani_segments_path
    parsed_nyas = compmusic_raga.load_nyas_segments(nyas_segments_path)
    parsed_tani = compmusic_raga.load_tani_segments(tani_segments_path)

    # Check types
    assert type(parsed_nyas) is annotations.EventData
    assert type(parsed_nyas.intervals) is np.ndarray
    assert type(parsed_nyas.events) is list
    assert type(parsed_tani) is annotations.EventData
    assert type(parsed_tani.intervals) is np.ndarray
    assert type(parsed_tani.events) is list

    # Check values
    assert np.array_equal(
        parsed_nyas.intervals,
        np.array(
            [
                [2.16887, 2.62664],
                [3.04886, 3.43552],
                [5.19106, 5.50217],
            ]
        ),
    )
    assert parsed_nyas.events == ["nyas", "nyas", "nyas"]
    assert np.array_equal(
        parsed_tani.intervals,
        np.array(
            [
                [2.16887, 2.62664],
                [3.04886, 3.43552],
                [5.19106, 5.50217],
            ]
        ),
    )
    assert parsed_tani.events == ["tani", "tani", "tani"]

    assert compmusic_raga.load_nyas_segments(None) is None
    assert compmusic_raga.load_tani_segments(None) is None

    empty_nyas_path = (
        "tests/resources/mir_datasets/compmusic_raga/RagaDataset/Carnatic/"
        + "features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/"
        + "Valli_Kanavan/Valli_Kanavan_empty.flatSegNyas"
    )
    empty_tani_path = (
        "tests/resources/mir_datasets/compmusic_raga/RagaDataset/Carnatic/"
        + "features/3af5a361-923a-465d-864d-9c7ba0c04a47/Aruna_Sairam/December_Season_2001/"
        + "Valli_Kanavan/Valli_Kanavan_empty.taniSegKNN"
    )
    assert compmusic_raga.load_nyas_segments(empty_nyas_path) is None
    assert compmusic_raga.load_tani_segments(empty_tani_path) is None


def test_load_audio():
    data_home = "tests/resources/mir_datasets/compmusic_raga"
    dataset = compmusic_raga.Dataset(data_home, version="test")
    track = dataset.track("Aruna_Sairam.Valli_Kanavan")
    audio_path = track.audio_path
    audio, sr = compmusic_raga.load_audio(audio_path)

    assert sr == 44100
    assert type(audio) == np.ndarray
    assert audio.shape[0] == 2

    assert compmusic_raga.load_audio(None) is None


def test_dataset_metadata():
    data_home = "tests/resources/mir_datasets/compmusic_raga"
    dataset = compmusic_raga.Dataset(data_home, version="test")
    carnatic_mapping_path = os.path.join(
        data_home,
        "RagaDataset",
        "Carnatic",
        "_info_",
        "ragaId_to_ragaName_mapping.json",
    )
    with pytest.raises(FileNotFoundError):
        dataset.get_metadata(
            {}, "a/fake/path", carnatic_mapping_path, "carnatic"
        )
