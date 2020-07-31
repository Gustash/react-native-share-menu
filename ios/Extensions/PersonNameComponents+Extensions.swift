//
//  PersonNameComponents+Extensions.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 31/07/2020.
//

extension PersonNameComponents {
    init(from dict: [String:Any]) {
        self.init()

        self.namePrefix = dict[NAME_PREFIX_KEY] as? String
        self.givenName = dict[GIVEN_NAME_KEY] as? String
        self.middleName = dict[MIDDLE_NAME_KEY] as? String
        self.familyName = dict[FAMILY_NAME_KEY] as? String
        self.nameSuffix = dict[NAME_SUFFIX_KEY] as? String
        self.nickname = dict[NICKNAME_KEY] as? String
        if let phoneticRepresentation = dict[PHONETIC_REPRESENTATION_KEY] as? [String:String] {
            self.phoneticRepresentation = PersonNameComponents.init(from: phoneticRepresentation)
        }
    }
}
