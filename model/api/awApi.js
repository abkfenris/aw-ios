'use strict'

const _ = require('lodash')
const queryString = require('query-string')

// Urls
const BASE_URL = 'https://www.americanwhitewater.org/content/'

const PHOTO_BASE_URL = 'https://www.americanwhitewater.org/photos/archive/'
const ARTICLE_PHOTO_BASE_URL = 'https://www.americanwhitewater.org/resources/images/abstract/'
function flowGraphUrl(gageId, metricId) {
     return `https://www.americanwhitewater.org/content/Gauge2/graph/id/${gageId}/metric/${metricId}/.raw`
}

const SEARCH_ENDPOINT = 'River/search/.json'
const GEO_SEARCH_ENDPOINT = 'River/geo-summary/.json'
const ARTICLE_LIST_ENDPOINT = 'News/all/type/frontpagenews/subtype//page/0/.json?limit=10'
function getReachListEndpoint(reachIds) {
    return `River/list/list/${reachIds}/.json`
}
function getReachDetailEndpoint(reachId) {
    return `River/detail/id/${reachId}/.json`
}
function getGageDetailEndpoint(gageId) {
    return `Gauge2/detail/id/${gageId}/.json`
}

module.exports.getReachesBySearch = getReachesBySearch
module.exports.getReachesByGeo = getReachesByGeo
module.exports.getReachesByFilter = getReachesByFilter
module.exports.getReachList = getReachList
module.exports.getReach = getReach
module.exports.getGageReaches = getGageReaches
module.exports.getArticlesList = getArticlesList
module.exports.getPhotoUrl = getPhotoUrl
module.exports.getArticlePhotoUrl = getArticlePhotoUrl
module.exports.getFlowGraphUrl = getFlowGraphUrl


async function getReachesBySearch(searchText) {
    const url = _urlWithParams(BASE_URL + SEARCH_ENDPOINT, {
        river: searchText
    })
    
    const searchResponses = await _fetchJson(url)
    const results = _parseReachSearchResults(searchResponses)
    
    return results
}

async function getReachesByGeo(bounds) {
    const boundsString = [bounds.sw.lng, bounds.sw.lat, bounds.ne.lng, bounds.ne.lat].join()
    const url = _urlWithParams(BASE_URL + GEO_SEARCH_ENDPOINT, {
        BBOX: boundsString
    })
    
    const searchResponses = await _fetchJson(url)
    const results = _parseReachSearchResults(searchResponses)
    
    return results
}

async function getReachesByFilter(filter) {
    
}

/**
* @param {Array} reachIds
*/
async function getReachList(reachIds) {
    const url = BASE_URL + getReachListEndpoint(reachIds.join(':'))
    const responses = await _fetchJson(url)
    
    return _parseReachSearchResults(responses)
}

async function getReach(reachId) {
    const url = BASE_URL + getReachDetailEndpoint(reachId)
    const response = await _fetchJson(url)
    const reachDetailResponse = response.CContainerViewJSON_view.CRiverMainGadgetJSON_main.info
    
    const name = reachDetailResponse.altname ? reachDetailResponse.altname : reachDetailResponse.section
    const putinLatLng = _parseLatLng(reachDetailResponse.plat, reachDetailResponse.plon)
    const takeoutLatLng = _parseLatLng(reachDetailResponse.tlat, reachDetailResponse.tlon)
    
    return {
        id: reachDetailResponse.id,
        name: name,
        sectionName: reachDetailResponse.section,
        river: reachDetailResponse.river,
        photoId: reachDetailResponse.photoid,
        length: reachDetailResponse.length,
        difficulty: reachDetailResponse.class,
        avgGradient: reachDetailResponse.avggradient,
        maxGradient: reachDetailResponse.maxgradient,
        putinLatLng: putinLatLng,
        takeoutLatLng: takeoutLatLng,
        description: reachDetailResponse.description,
        shuttleDetails: reachDetailResponse.shuttledetails,
        // gages: reachDetailResponse,
        // rapids: reachDetailResponse,
    }
}

async function getGageReaches(gage) {
    const url = BASE_URL + getGageDetailEndpoint(gage.id)
    const response = await _fetchJson(url)
    const reachSearchResponses = response.riverinfo
    
    return _parseReachSearchResults(reachSearchResponses)
}

async function getArticlesList() {
    const response = await _fetchJson(BASE_URL + ARTICLE_LIST_ENDPOINT)
    const articleResponses = response.articles.CArticleGadgetJSON_view_list
    
    return articleResponses
}

async function getArticlePhotoUrl(articleId, abstractPhotoNumber) {
    return ARTICLE_PHOTO_BASE_URL + articleId + "-" + abstractPhotoNumber + ".jpg"
}

async function getFlowGraphUrl(gage) {
    if (!gage.awGageMetricId) {
        return ""
    } else {
        return flowGraphUrl(gage.id, gage.awGageMetricId)
    }
}

function getPhotoUrl(photoId) {
    return PHOTO_BASE_URL + photoId + '.jpg'
}

// Returns a latLng object
function _parseLatLng(lat, lng) {
    return  {
        lat: lat, 
        lng: lng
    }
}

function _parseReachSearchResults(reachSearchResponses) {
    return _.map(reachSearchResponses, function(response) {
        const name = response.altname ? response.altname : response.section
        const putinLatLng = _parseLatLng(response.plat, response.plon)
        return {
            id: response.id,
            name: name,
            river: response.river,
            difficulty: response.class,
            lastGageReading: response.reading_formatted,
            // TODO flowLevel: ,
            putInLatLng: putinLatLng
        }
    })
}

function _urlWithParams(url, params) {
    return url + '?' + queryString.stringify(params)
}

async function _fetchJson(url, options) {
    try {
        const response = await fetch(url, options)
        return await response.json()
    } catch (err) {
        console.log(err)
    }
}
